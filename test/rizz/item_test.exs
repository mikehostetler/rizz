defmodule Rizz.ItemTest do
  use ExUnit.Case

  alias Rizz.Item

  describe "new/1" do
    test "creates a new item with given attributes" do
      attrs = %{
        title: "Test Item",
        description: "A test item",
        ai_model: ["GPT", "Grok"],
        ai_context: "Testing context",
        ai_data_quality: 75
      }

      item = Item.new(attrs)

      assert item.title == "Test Item"
      assert item.description == "A test item"
      assert item.ai_model == ["GPT", "Grok"]
      assert item.ai_context == "Testing context"
      assert item.ai_data_quality == 75
    end
  end

  describe "compatible_with_model?/2" do
    test "returns true when model name is in item's ai_model list" do
      item = Item.new(%{ai_model: ["GPT", "Grok", "Claude"]})

      assert Item.compatible_with_model?(item, "GPT") == true
      assert Item.compatible_with_model?(item, "Grok") == true
      assert Item.compatible_with_model?(item, "Claude") == true
    end

    test "returns true when model name contains item's model" do
      item = Item.new(%{ai_model: ["GPT"]})

      assert Item.compatible_with_model?(item, "GPT-4") == true
    end

    test "returns true when item's model contains model name" do
      item = Item.new(%{ai_model: ["GPT-4"]})

      assert Item.compatible_with_model?(item, "GPT") == true
    end

    test "returns false when model is not compatible" do
      item = Item.new(%{ai_model: ["GPT", "Grok"]})

      assert Item.compatible_with_model?(item, "Claude") == false
      assert Item.compatible_with_model?(item, "Llama") == false
    end

    test "returns false when model list is nil" do
      item = Item.new(%{})

      assert Item.compatible_with_model?(item, "GPT") == false
    end

    test "handles single string model specification" do
      item = Item.new(%{ai_model: "GPT, Grok"})

      assert Item.compatible_with_model?(item, "GPT") == true
      assert Item.compatible_with_model?(item, "Grok") == true
      assert Item.compatible_with_model?(item, "Claude") == false
    end
  end

  describe "data_quality/1" do
    test "returns the integer quality value" do
      item = Item.new(%{ai_data_quality: 85})

      assert Item.data_quality(item) == 85
    end

    test "parses string quality value" do
      item = Item.new(%{ai_data_quality: "75"})

      assert Item.data_quality(item) == 75
    end

    test "returns 0 for nil quality" do
      item = Item.new(%{})

      assert Item.data_quality(item) == 0
    end

    test "returns 0 for invalid quality format" do
      item = Item.new(%{ai_data_quality: "high"})

      assert Item.data_quality(item) == 0
    end
  end
end
