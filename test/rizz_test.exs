defmodule RizzTest do
  use ExUnit.Case
  doctest Rizz

  alias Rizz.{Feed, Item}

  describe "feed creation" do
    test "creates a new feed" do
      feed = Rizz.new_feed(
        title: "AI News Feed",
        link: "https://example.com/ai-news",
        description: "AI updates for bots"
      )

      assert feed.title == "AI News Feed"
      assert feed.link == "https://example.com/ai-news"
      assert feed.description == "AI updates for bots"
      assert feed.items == []
    end

    test "adds items to a feed" do
      feed = Rizz.new_feed(title: "AI News Feed")

      feed = Rizz.add_item(feed, %{
        title: "AI Update",
        description: "New models",
        ai_model: ["GPT", "Grok"]
      })

      assert length(feed.items) == 1
      item = hd(feed.items)
      assert item.title == "AI Update"
      assert item.description == "New models"
      assert item.ai_model == ["GPT", "Grok"]
    end
  end

  describe "filtering feed items" do
    setup do
      item1 = Item.new(%{
        title: "GPT Update",
        ai_model: ["GPT"],
        ai_data_quality: 90
      })

      item2 = Item.new(%{
        title: "Grok Update",
        ai_model: ["Grok"],
        ai_data_quality: 70
      })

      item3 = Item.new(%{
        title: "Claude Update",
        ai_model: ["Claude"],
        ai_data_quality: 60
      })

      items = [item1, item2, item3]

      %{items: items}
    end

    test "filters by model", %{items: items} do
      gpt_items = Rizz.filter_by_model(items, "GPT")
      assert length(gpt_items) == 1
      assert hd(gpt_items).title == "GPT Update"

      grok_items = Rizz.filter_by_model(items, "Grok")
      assert length(grok_items) == 1
      assert hd(grok_items).title == "Grok Update"
    end

    test "filters by data quality", %{items: items} do
      high_quality = Rizz.filter_by_quality(items, min_quality: 80)
      assert length(high_quality) == 1
      assert hd(high_quality).title == "GPT Update"

      medium_quality = Rizz.filter_by_quality(items, min_quality: 70)
      assert length(medium_quality) == 2

      all_quality = Rizz.filter_by_quality(items, min_quality: 0)
      assert length(all_quality) == 3
    end
  end

  describe "XML generation" do
    test "generates valid RIZZ XML" do
      feed = Rizz.new_feed(
        title: "AI News Feed",
        link: "https://example.com/ai-news",
        description: "AI updates for bots"
      )

      feed = Rizz.add_item(feed, %{
        title: "AI Update",
        link: "https://example.com/update",
        description: "New models",
        pub_date: ~U[2023-01-01 12:00:00Z],
        ai_model: ["GPT", "Grok"],
        ai_context: "Summarize for developers",
        ai_data_quality: 85
      })

      xml = Rizz.to_xml(feed)

      # Basic assertions
      assert xml =~ ~s(<?xml version="1.0" encoding="UTF-8"?>)
      assert xml =~ ~s(<rss version="2.0")
      assert xml =~ ~s(xmlns:ai="http://xai.org/RIZZ-namespace")
      assert xml =~ ~s(<title>AI News Feed</title>)
      assert xml =~ ~s(<title>AI Update</title>)
      assert xml =~ ~s(<ai:model>GPT, Grok</ai:model>)
      assert xml =~ ~s(<ai:context>Summarize for developers</ai:context>)
      assert xml =~ ~s(<ai:dataQuality>85</ai:dataQuality>)
    end

    test "includes JSON-LD when provided" do
      feed = Rizz.new_feed(title: "AI News Feed")

      json_ld = %{
        "@context" => "https://schema.org",
        "@type" => "Article",
        "headline" => "AI Update"
      }

      feed = Rizz.add_item(feed, %{
        title: "AI Update",
        description: "New models",
        json_ld: json_ld
      })

      xml = Rizz.to_xml(feed)

      assert xml =~ ~s(<script type="application/ld+json">)
      assert xml =~ ~s("@context":"https://schema.org")
    end
  end

  describe "parsing" do
    test "parses basic RSS with RIZZ metadata" do
      xml = """
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0" xmlns:ai="http://xai.org/RIZZ-namespace">
        <channel>
          <title>AI News Feed</title>
          <link>https://example.com/ai-news</link>
          <description>AI updates for bots</description>
          <language>en-us</language>
          <item>
            <title>AI Reasoning Breakthrough</title>
            <link>https://example.com/news/reasoning</link>
            <guid>https://example.com/news/reasoning</guid>
            <description>New AI logic techniques.</description>
            <pubDate>Mon, 10 Mar 2025 01:45:00 EDT</pubDate>
            <ai:model>Grok, GPT</ai:model>
            <ai:context>Summarize for developers</ai:context>
            <ai:dataQuality>90</ai:dataQuality>
          </item>
        </channel>
      </rss>
      """

      assert {:ok, feed} = Rizz.parse(xml)
      assert feed.title == "AI News Feed"
      assert feed.subtitle == "AI updates for bots"
      assert feed.url == "https://example.com/ai-news"

      assert length(feed.entries) == 1
      entry = hd(feed.entries)

      assert entry.title == "AI Reasoning Breakthrough"
      assert entry.url == "https://example.com/news/reasoning"
      assert entry.ai_models == ["Grok", "GPT"]
      assert entry.ai_context == "Summarize for developers"
      assert entry.ai_data_quality == 90
    end

    test "parses RSS with JSON-LD" do
      xml = """
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0" xmlns:ai="http://xai.org/RIZZ-namespace">
        <channel>
          <title>AI News Feed</title>
          <link>https://example.com/ai-news</link>
          <description>AI updates for bots</description>
          <item>
            <title>AI Update</title>
            <link>https://example.com/update</link>
            <guid>https://example.com/update</guid>
            <description>New models</description>
            <ai:model>GPT</ai:model>
            <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "headline": "AI Update",
              "url": "https://example.com/update"
            }
            </script>
          </item>
        </channel>
      </rss>
      """

      assert {:ok, feed} = Rizz.parse(xml)
      assert length(feed.entries) == 1

      entry = hd(feed.entries)
      assert entry.json_ld != nil
      assert entry.json_ld["@context"] == "https://schema.org"
      assert entry.json_ld["@type"] == "Article"
      assert entry.json_ld["headline"] == "AI Update"
    end
  end

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
end
