defmodule Rizz.FeaturesTest do
  use ExUnit.Case

  describe "filtering" do
    test "filters by AI model" do
      gpt_entry = %{title: "GPT Update", ai_models: ["GPT", "Grok"]}
      claude_entry = %{title: "Claude Update", ai_models: ["Claude"]}

      feed = %{
        title: "AI Feed",
        entries: [gpt_entry, claude_entry]
      }

      gpt_feed = Rizz.filter_by_model(feed, "GPT")
      assert length(gpt_feed.entries) == 1
      assert hd(gpt_feed.entries).title == "GPT Update"

      claude_feed = Rizz.filter_by_model(feed, "Claude")
      assert length(claude_feed.entries) == 1
      assert hd(claude_feed.entries).title == "Claude Update"

      empty_feed = Rizz.filter_by_model(feed, "Llama")
      assert empty_feed.entries == []
    end

    test "filters by data quality" do
      high_quality = %{title: "High Quality", ai_data_quality: 90}
      medium_quality = %{title: "Medium Quality", ai_data_quality: 70}
      low_quality = %{title: "Low Quality", ai_data_quality: 30}

      feed = %{
        title: "Quality Feed",
        entries: [high_quality, medium_quality, low_quality]
      }

      high_feed = Rizz.filter_by_quality(feed, min_quality: 80)
      assert length(high_feed.entries) == 1
      assert hd(high_feed.entries).title == "High Quality"

      medium_feed = Rizz.filter_by_quality(feed, min_quality: 50)
      assert length(medium_feed.entries) == 2

      all_feed = Rizz.filter_by_quality(feed)
      assert length(all_feed.entries) == 3
    end
  end

  describe "metadata extraction" do
    test "gets AI context" do
      item = %{ai_context: "Summarize for developers"}
      assert Rizz.get_ai_context(item) == "Summarize for developers"
    end

    test "gets AI models" do
      item = %{ai_models: ["GPT", "Grok"]}
      assert Rizz.get_ai_models(item) == ["GPT", "Grok"]
    end

    test "gets data quality" do
      item = %{ai_data_quality: 90}
      assert Rizz.get_data_quality(item) == 90

      item_without_quality = %{}
      assert Rizz.get_data_quality(item_without_quality) == 0
    end

    test "gets JSON-LD" do
      json_ld = %{"@context" => "https://schema.org"}
      item = %{json_ld: json_ld}
      assert Rizz.get_json_ld(item) == json_ld
    end
  end

  describe "model compatibility" do
    test "checks compatibility with model" do
      item_with_list = %{ai_models: ["GPT", "Grok"]}
      assert Rizz.compatible_with_model?(item_with_list, "GPT") == true
      assert Rizz.compatible_with_model?(item_with_list, "Claude") == false

      # Test partial matching
      assert Rizz.compatible_with_model?(item_with_list, "GPT-4") == true

      # Test with no models
      item_without_models = %{}
      assert Rizz.compatible_with_model?(item_without_models, "GPT") == false
    end
  end

  describe "namespace" do
    test "returns AI namespace" do
      assert Rizz.ai_namespace() == "http://xai.org/RIZZ-namespace"
    end
  end
end
