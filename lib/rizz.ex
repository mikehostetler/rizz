defmodule Rizz do
  @moduledoc """
  Rizz is an Elixir package for working with RSS Information Zone Zapper (RIZZ) feeds.

  RIZZ is a specification for AI-optimized RSS feeds, extending standard RSS 2.0
  with AI-specific metadata using XML namespaces.
  """

  alias Rizz.{Feed, Parser}

  @ai_namespace "http://xai.org/RIZZ-namespace"

  @doc """
  Fetches a RIZZ feed from the given URL.

  ## Options

  * `:headers` - HTTP headers for the request, useful for authentication.
  * `:follow_redirects` - Whether to follow redirects. Default is true.

  ## Examples

      # Not run in tests - requires HTTP
      # iex> Rizz.fetch("https://example.com/RIZZ.xml")
      # {:ok, %Rizz.Feed{}}
      #
      # iex> Rizz.fetch("https://example.com/RIZZ.xml",
      # ...>   headers: [{"Authorization", "Bearer token"}])
      # {:ok, %Rizz.Feed{}}

  """
  @spec fetch(String.t(), Keyword.t()) :: {:ok, Feed.t()} | {:error, any()}
  def fetch(url, opts \\ []) do
    headers = Keyword.get(opts, :headers, [])
    follow_redirects = Keyword.get(opts, :follow_redirects, true)

    req_opts = [
      headers: headers,
      max_redirects: if(follow_redirects, do: 5, else: 0)
    ]

    case Req.get(url, req_opts) do
      {:ok, %{status: 200, body: body}} ->
        Parser.parse(body)

      {:ok, %{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, {:http_error, reason}}
    end
  end

  @doc """
  Parses RIZZ XML content into a Feed struct.

  ## Example

      iex> xml = ~s(<?xml version="1.0"?><rss version="2.0"><channel><title>AI Feed</title></channel></rss>)
      iex> {:ok, feed} = Rizz.parse(xml)
      iex> feed.title
      "AI Feed"

  """
  @spec parse(String.t()) :: {:ok, Feed.t()} | {:error, any()}
  def parse(xml) do
    Parser.parse(xml)
  end

  @doc """
  Filters feed items by AI model compatibility.

  ## Example

      iex> feed = %{entries: [%{ai_models: ["GPT", "Grok"]}, %{ai_models: ["Claude"]}]}
      iex> gpt_feed = Rizz.filter_by_model(feed, "GPT")
      iex> length(gpt_feed.entries)
      1

  """
  @spec filter_by_model(map(), String.t()) :: map()
  def filter_by_model(feed, model) do
    filtered_entries =
      Enum.filter(feed.entries, fn entry ->
        compatible_with_model?(entry, model)
      end)

    %{feed | entries: filtered_entries}
  end

  @doc """
  Filters feed items by AI data quality.

  ## Options

  * `:min_quality` - Minimum quality score (0-100). Default is 0.

  ## Example

      iex> feed = %{entries: [%{ai_data_quality: 90}, %{ai_data_quality: 50}]}
      iex> quality_feed = Rizz.filter_by_quality(feed, min_quality: 80)
      iex> length(quality_feed.entries)
      1

  """
  @spec filter_by_quality(map(), Keyword.t()) :: map()
  def filter_by_quality(feed, opts \\ []) do
    min_quality = Keyword.get(opts, :min_quality, 0)

    filtered_entries =
      Enum.filter(feed.entries, fn entry ->
        get_data_quality(entry) >= min_quality
      end)

    %{feed | entries: filtered_entries}
  end

  @doc """
  Gets the AI context for a feed entry.

  ## Example

      iex> entry = %{ai_context: "Summarize for developers"}
      iex> Rizz.get_ai_context(entry)
      "Summarize for developers"

  """
  @spec get_ai_context(map()) :: String.t() | nil
  def get_ai_context(entry) do
    Map.get(entry, :ai_context)
  end

  @doc """
  Gets the AI models for a feed entry.

  ## Example

      iex> entry = %{ai_models: ["GPT", "Grok"]}
      iex> Rizz.get_ai_models(entry)
      ["GPT", "Grok"]

  """
  @spec get_ai_models(map()) :: [String.t()] | nil
  def get_ai_models(entry) do
    Map.get(entry, :ai_models)
  end

  @doc """
  Gets the data quality value for a feed entry.

  ## Example

      iex> entry = %{ai_data_quality: 90}
      iex> Rizz.get_data_quality(entry)
      90

  """
  @spec get_data_quality(map()) :: integer()
  def get_data_quality(entry) do
    Map.get(entry, :ai_data_quality, 0)
  end

  @doc """
  Gets the JSON-LD data for a feed entry.

  ## Example

      iex> entry = %{json_ld: %{"@context" => "https://schema.org"}}
      iex> Rizz.get_json_ld(entry)
      %{"@context" => "https://schema.org"}

  """
  @spec get_json_ld(map()) :: map() | nil
  def get_json_ld(entry) do
    Map.get(entry, :json_ld)
  end

  @doc """
  Checks if an entry is compatible with the specified AI model.

  ## Example

      iex> entry = %{ai_models: ["GPT", "Grok"]}
      iex> Rizz.compatible_with_model?(entry, "GPT")
      true

  """
  @spec compatible_with_model?(map(), String.t()) :: boolean()
  def compatible_with_model?(entry, model) do
    case get_ai_models(entry) do
      nil ->
        false

      models when is_list(models) ->
        Enum.any?(models, fn m ->
          String.contains?(m, model) || String.contains?(model, m)
        end)

      model_string when is_binary(model_string) ->
        String.contains?(model_string, model) || String.contains?(model, model_string)
    end
  end

  @doc """
  Returns the AI namespace URI used in RIZZ.

  ## Example

      iex> Rizz.ai_namespace()
      "http://xai.org/RIZZ-namespace"

  """
  @spec ai_namespace() :: String.t()
  def ai_namespace do
    @ai_namespace
  end

  @doc """
  Creates a new RIZZ feed with the given options.

  ## Options

  * `:title` - Feed title (required)
  * `:link` - Feed link
  * `:description` - Feed description
  * `:language` - Feed language
  * `:pub_date` - Publication date
  * `:last_build_date` - Last build date
  * `:generator` - Feed generator
  * `:ttl` - Time to live

  ## Example

      iex> feed = Rizz.new_feed(title: "AI News Feed")
      iex> feed.title
      "AI News Feed"

  """
  @spec new_feed(Keyword.t()) :: Feed.t()
  def new_feed(opts) do
    Feed.new(opts)
  end

  @doc """
  Adds an item to a RIZZ feed.

  ## Example

      iex> feed = Rizz.new_feed(title: "AI News Feed")
      iex> feed = Rizz.add_item(feed, %{title: "AI Update", ai_model: ["GPT"]})
      iex> length(feed.items)
      1

  """
  @spec add_item(Feed.t(), map()) :: Feed.t()
  def add_item(feed, item) do
    Feed.add_item(feed, item)
  end

  @doc """
  Converts a feed to RIZZ-compliant XML.

  ## Example

      iex> feed = Rizz.new_feed(title: "AI News Feed")
      iex> xml = Rizz.to_xml(feed)
      iex> String.contains?(xml, "<title>AI News Feed</title>")
      true

  """
  @spec to_xml(Feed.t()) :: String.t()
  def to_xml(feed) do
    Rizz.Builder.to_xml(feed)
  end
end
