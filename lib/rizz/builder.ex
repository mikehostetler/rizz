defmodule Rizz.Builder do
  @moduledoc """
  Handles the generation of RIZZ-compliant XML from Feed structs.
  """

  alias Rizz.Feed
  require SweetXml

  @doc """
  Converts a Feed struct to RIZZ-compliant XML.

  ## Example

      iex> feed = Rizz.Feed.new(title: "AI News", link: "https://example.com", description: "AI updates")
      iex> Rizz.Builder.to_xml(feed)
      "<?xml version=\\"1.0\\" encoding=\\"UTF-8\\"?><rss version=\\"2.0\\" xmlns:ai=\\"http://xai.org/RIZZ-namespace\\">...</rss>"

  """
  @spec to_xml(Feed.t()) :: String.t()
  def to_xml(feed) do
    rss_element = build_rss_element(feed)

    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" <>
      XmlBuilder.generate(rss_element, format: :none)
  end

  # Private helper functions

  defp build_rss_element(feed) do
    {"rss", [{"version", "2.0"}, {"xmlns:ai", Rizz.ai_namespace()}],
     [
       build_channel_element(feed)
     ]}
  end

  defp build_channel_element(feed) do
    {"channel", [],
     [
       build_element("title", feed.title),
       build_element("link", feed.link),
       build_element("description", feed.description),
       build_element("language", feed.language),
       build_element("pubDate", format_datetime(feed.pub_date)),
       build_element("lastBuildDate", format_datetime(feed.last_build_date)),
       build_element("generator", feed.generator),
       build_element("ttl", feed.ttl)
     ]
     |> Enum.reject(&is_nil/1)
     |> Enum.concat(Enum.map(feed.items, &build_item_element/1))}
  end

  defp build_item_element(item) do
    standard_elements =
      [
        build_element("title", item.title),
        build_element("link", item.link),
        build_element("description", item.description),
        build_element("pubDate", format_datetime(item.pub_date)),
        build_element("guid", item.guid),
        build_element("author", item.author),
        build_element("category", item.category)
      ]
      |> Enum.reject(&is_nil/1)

    ai_elements =
      [
        build_ai_element("model", format_models(item.ai_model)),
        build_ai_element("context", item.ai_context),
        build_ai_element("dataQuality", item.ai_data_quality)
      ]
      |> Enum.reject(&is_nil/1)

    json_ld_element =
      if item.json_ld do
        {"script", [{"type", "application/ld+json"}], [Jason.encode!(item.json_ld)]}
      else
        nil
      end

    all_elements =
      standard_elements
      |> Enum.concat(ai_elements)
      |> Enum.concat(if json_ld_element, do: [json_ld_element], else: [])

    {"item", [], all_elements}
  end

  defp build_element(_name, nil), do: nil

  defp build_element(name, value) when is_binary(value) or is_integer(value),
    do: {name, [], [to_string(value)]}

  defp build_element(_name, _value), do: nil

  defp build_ai_element(_name, nil), do: nil

  defp build_ai_element(name, value) when is_binary(value) or is_integer(value),
    do: {"ai:" <> name, [], [to_string(value)]}

  defp build_ai_element(_name, _value), do: nil

  defp format_datetime(nil), do: nil

  defp format_datetime(%DateTime{} = dt) do
    # Format manually to avoid Timex range warning
    day = String.pad_leading(to_string(dt.day), 2, "0")
    month = String.pad_leading(to_string(dt.month), 2, "0")
    year = dt.year
    hour = String.pad_leading(to_string(dt.hour), 2, "0")
    minute = String.pad_leading(to_string(dt.minute), 2, "0")
    second = String.pad_leading(to_string(dt.second), 2, "0")
    zone = dt.time_zone

    "#{day} #{month} #{year} #{hour}:#{minute}:#{second} #{zone}"
  end

  defp format_datetime(dt), do: dt

  defp format_models(nil), do: nil
  defp format_models(models) when is_list(models), do: Enum.join(models, ", ")
  defp format_models(model), do: model
end
