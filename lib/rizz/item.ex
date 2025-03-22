defmodule Rizz.Item do
  @moduledoc """
  Represents an item in a RIZZ feed, including AI-specific metadata.
  """

  @type t :: %__MODULE__{
    title: String.t() | nil,
    link: String.t() | nil,
    description: String.t() | nil,
    pub_date: DateTime.t() | nil,
    guid: String.t() | nil,
    author: String.t() | nil,
    category: String.t() | nil,
    ai_model: [String.t()] | nil,
    ai_context: String.t() | nil,
    ai_data_quality: integer() | nil,
    json_ld: map() | nil
  }

  defstruct [
    :title,
    :link,
    :description,
    :pub_date,
    :guid,
    :author,
    :category,
    :ai_model,
    :ai_context,
    :ai_data_quality,
    :json_ld
  ]

  @doc """
  Creates a new RIZZ feed item with the given attributes.

  ## Example

      iex> Rizz.Item.new(%{title: "AI Update", description: "New models", ai_model: ["GPT", "Grok"]})
      %Rizz.Item{title: "AI Update", description: "New models", ai_model: ["GPT", "Grok"]}

  """
  @spec new(map()) :: t()
  def new(attrs \\ %{}) do
    struct(__MODULE__, attrs)
  end

  @doc """
  Checks if an item is compatible with the specified AI model.

  ## Example

      iex> item = Rizz.Item.new(%{ai_model: ["GPT", "Grok"]})
      iex> Rizz.Item.compatible_with_model?(item, "GPT")
      true

      iex> Rizz.Item.compatible_with_model?(item, "Claude")
      false

  """
  @spec compatible_with_model?(t(), String.t()) :: boolean()
  def compatible_with_model?(item, model) do
    case item.ai_model do
      nil -> false
      models when is_list(models) ->
        Enum.any?(models, fn m ->
          String.contains?(m, model) || String.contains?(model, m)
        end)
      model_string when is_binary(model_string) ->
        String.contains?(model_string, model) || String.contains?(model, model_string)
    end
  end

  @doc """
  Returns the data quality of an item.

  ## Example

      iex> item = Rizz.Item.new(%{ai_data_quality: 85})
      iex> Rizz.Item.data_quality(item)
      85

      iex> item = Rizz.Item.new(%{})
      iex> Rizz.Item.data_quality(item)
      0

  """
  @spec data_quality(t()) :: integer()
  def data_quality(item) do
    case item.ai_data_quality do
      nil -> 0
      quality when is_integer(quality) -> quality
      quality when is_binary(quality) ->
        case Integer.parse(quality) do
          {value, _} -> value
          :error -> 0
        end
      _ -> 0
    end
  end
end
