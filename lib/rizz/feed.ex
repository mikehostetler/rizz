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
  def from_standard_feed(feed, opts \\ []) do
    feed
  end

  @doc """
  Creates a new feed with the given properties.
  """
  def new(props \\ %{}) do
    %{
      title: Map.get(props, :title),
      description: Map.get(props, :description),
      url: Map.get(props, :url),
      entries: Map.get(props, :entries, [])
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
