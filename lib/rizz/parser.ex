defmodule Rizz.Parser do
  @moduledoc """
  Responsible for parsing RIZZ XML feeds into Elixir data structures.

  Uses ElixirFeedParser as the base parser and extends it with AI metadata
  from the RIZZ specification.
  """

  import SweetXml, only: [sigil_x: 2, xpath: 2, xpath: 3]

  @ai_namespace Rizz.ai_namespace()

  @doc """
  Parses a RIZZ XML string into a Feed struct.

  ## Example

      iex> xml = "<?xml version=\\"1.0\\"?><rss version=\\"2.0\\"><channel><title>Feed</title></channel></rss>"
      iex> {:ok, feed} = Rizz.Parser.parse(xml)
      iex> feed.title
      "Feed"

  """
  @spec parse(String.t()) :: {:ok, map()} | {:error, any}
  def parse(xml) do
    try do
      # First use ElixirFeedParser to parse the standard RSS elements
      case ElixirFeedParser.parse(xml) do
        {:ok, feed} ->
          # Now enhance the feed with RIZZ-specific AI metadata
          enhanced_feed = enhance_with_ai_metadata(feed, xml)
          {:ok, enhanced_feed}

        {:error, reason} ->
          {:error, reason}
      end
    rescue
      e -> {:error, e}
    end
  end

  @doc """
  Enhances a standard feed with RIZZ AI metadata.
  """
  def enhance_with_ai_metadata(feed, xml) do
    # First enhance the feed items with AI metadata
    entries_with_ai = Enum.map(feed.entries, fn entry ->
      guid = entry.id

      # Use the SweetXml xpath to find the corresponding item in the XML
      # and extract AI metadata from it
      item_xpath = ~x"//item[guid='#{guid}' or link='#{entry.url}']"

      # If the exact item can't be found, try to match by position
      item_node = if xpath(xml, item_xpath, nil) do
        xpath(xml, item_xpath)
      else
        # Fallback to position - find the index in the feed entries
        index = Enum.find_index(feed.entries, fn e -> e.id == entry.id end) || 0
        xpath(xml, ~x"//item[#{index + 1}]", nil)
      end

      if item_node do
        # Extract AI metadata
        ai_model = xpath(item_node, ~x"./ai:model/text()"s, namespace_options: [{"ai", @ai_namespace}])
        ai_context = xpath(item_node, ~x"./ai:context/text()"s, namespace_options: [{"ai", @ai_namespace}])
        ai_data_quality = xpath(item_node, ~x"./ai:dataQuality/text()"i, namespace_options: [{"ai", @ai_namespace}])

        # Extract JSON-LD if present
        json_ld = extract_json_ld(item_node)

        # Add AI metadata to the entry
        entry
        |> Map.put(:ai_models, parse_models(ai_model))
        |> Map.put(:ai_context, if(ai_context == "", do: nil, else: ai_context))
        |> Map.put(:ai_data_quality, ai_data_quality)
        |> Map.put(:json_ld, json_ld)
      else
        entry
      end
    end)

    # Replace the entries in the feed with the enhanced ones
    %{feed | entries: entries_with_ai}
  end

  @doc """
  Extracts JSON-LD data from a script tag if present.
  """
  def extract_json_ld(item_node) do
    json_ld_xpath = ~x"./script[@type='application/ld+json']/text()"s
    json_ld_text = xpath(item_node, json_ld_xpath)

    if json_ld_text != "" do
      case Jason.decode(json_ld_text) do
        {:ok, json} -> json
        _ -> nil
      end
    else
      nil
    end
  end

  @doc """
  Parses the AI models string into a list of model names.
  """
  def parse_models(models_str) when is_binary(models_str) and models_str != "" do
    models_str
    |> String.split(",")
    |> Enum.map(&String.trim/1)
  end

  def parse_models(_), do: nil
end
