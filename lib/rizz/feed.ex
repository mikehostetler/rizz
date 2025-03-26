defmodule Rizz.Feed do
  @moduledoc """
  Type definition and helpers for RIZZ feeds.

  RIZZ feeds extend standard RSS feeds with AI-specific metadata.
  """

  alias Rizz.Item

  @type t :: %__MODULE__{
          title: String.t() | nil,
          link: String.t() | nil,
          description: String.t() | nil,
          language: String.t() | nil,
          pub_date: DateTime.t() | nil,
          last_build_date: DateTime.t() | nil,
          generator: String.t() | nil,
          ttl: non_neg_integer() | nil,
          items: [Item.t()]
        }

  defstruct [
    :title,
    :link,
    :description,
    :language,
    :pub_date,
    :last_build_date,
    :generator,
    :ttl,
    items: []
  ]

  @doc """
  Converts a standard ElixirFeedParser feed to RIZZ format.
  """
  def from_standard_feed(feed, _opts \\ []) do
    feed
  end

  @doc """
  Creates a new feed with the given properties.

  ## Example

      iex> feed = Rizz.Feed.new(title: "AI News")
      iex> feed.title
      "AI News"

  """
  def new(props \\ %{}) do
    props = if Keyword.keyword?(props), do: Map.new(props), else: props

    %__MODULE__{
      title: Map.get(props, :title),
      link: Map.get(props, :link),
      description: Map.get(props, :description),
      language: Map.get(props, :language),
      pub_date: Map.get(props, :pub_date),
      last_build_date: Map.get(props, :last_build_date),
      generator: Map.get(props, :generator),
      ttl: Map.get(props, :ttl),
      items: Map.get(props, :items, [])
    }
  end

  @doc """
  Adds an item to the feed.

  ## Example

      iex> feed = Rizz.Feed.new(title: "AI News")
      iex> Rizz.Feed.add_item(feed, %{title: "Update", description: "New model", ai_model: ["GPT"]})
      %Rizz.Feed{title: "AI News", items: [%Rizz.Item{title: "Update"}]}

  """
  @spec add_item(t(), map()) :: t()
  def add_item(feed, item_attrs) do
    item = Item.new(item_attrs)
    %{feed | items: feed.items ++ [item]}
  end
end
