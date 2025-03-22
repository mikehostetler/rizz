defmodule Rizz.IntegrationTest do
  use ExUnit.Case

  alias Rizz.{Feed, Item, Parser, Builder}

  describe "full round-trip (creation, serialization, parsing)" do
    test "generates and parses XML maintaining data integrity" do
      # Create a feed with items
      original_feed = Feed.new(
        title: "AI News Feed",
        link: "https://example.com/ai-news",
        description: "AI updates for bots",
        language: "en-us",
        generator: "Rizz Elixir Library",
        ttl: 60
      )

      # Add various items to test all features
      original_feed = Feed.add_item(original_feed, %{
        title: "AI Update 1",
        link: "https://example.com/update1",
        description: "New models released",
        pub_date: ~U[2023-01-01 12:00:00Z],
        guid: "update1",
        author: "AI Team",
        category: "Technology",
        ai_model: ["GPT", "Grok"],
        ai_context: "Summarize for developers",
        ai_data_quality: 90
      })

      original_feed = Feed.add_item(original_feed, %{
        title: "AI Update 2",
        link: "https://example.com/update2",
        description: "Research findings",
        ai_model: ["Claude"],
        ai_data_quality: 75,
        json_ld: %{
          "@context" => "https://schema.org",
          "@type" => "Article",
          "headline" => "AI Research Findings"
        }
      })

      # Convert to XML
      xml = Builder.to_xml(original_feed)

      # Parse XML back to feed
      {:ok, parsed_feed} = Parser.parse(xml)

      # Verify feed attributes are preserved
      assert parsed_feed.title == original_feed.title
      assert parsed_feed.link == original_feed.link
      assert parsed_feed.description == original_feed.description
      assert parsed_feed.language == original_feed.language
      assert parsed_feed.generator == original_feed.generator
      assert parsed_feed.ttl == original_feed.ttl

      # Verify items count
      assert length(parsed_feed.items) == length(original_feed.items)

      # Verify first item
      original_item1 = Enum.at(original_feed.items, 0)
      parsed_item1 = Enum.at(parsed_feed.items, 0)

      assert parsed_item1.title == original_item1.title
      assert parsed_item1.link == original_item1.link
      assert parsed_item1.description == original_item1.description
      assert parsed_item1.guid == original_item1.guid
      assert parsed_item1.author == original_item1.author
      assert parsed_item1.category == original_item1.category
      assert parsed_item1.ai_model == original_item1.ai_model
      assert parsed_item1.ai_context == original_item1.ai_context
      assert parsed_item1.ai_data_quality == original_item1.ai_data_quality

      # Verify second item with JSON-LD
      original_item2 = Enum.at(original_feed.items, 1)
      parsed_item2 = Enum.at(parsed_feed.items, 1)

      assert parsed_item2.title == original_item2.title
      assert parsed_item2.link == original_item2.link
      assert parsed_item2.ai_model == original_item2.ai_model
      assert parsed_item2.ai_data_quality == original_item2.ai_data_quality

      # JSON-LD should be preserved
      assert parsed_item2.json_ld != nil
      assert parsed_item2.json_ld["@context"] == original_item2.json_ld["@context"]
      assert parsed_item2.json_ld["@type"] == original_item2.json_ld["@type"]
      assert parsed_item2.json_ld["headline"] == original_item2.json_ld["headline"]
    end
  end

  describe "sample feed parsing" do
    @tag :external
    test "can create sample feed" do
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
            <description>New AI logic techniques.</description>
            <pubDate>Mon, 10 Mar 2025 01:45:00 EDT</pubDate>
            <ai:model>Grok, GPT</ai:model>
            <ai:context>Summarize for developers</ai:context>
            <ai:dataQuality>90</ai:dataQuality>
            <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "headline": "AI Reasoning Breakthrough",
              "url": "https://example.com/news/reasoning",
              "datePublished": "2025-03-10T01:45:00-04:00",
              "description": "New AI logic techniques.",
              "author": {
                "@type": "Organization",
                "name": "Example News"
              },
              "aiModel": ["Grok", "GPT"],
              "aiContext": "Summarize for developers",
              "aiDataQuality": 90
            }
            </script>
          </item>
        </channel>
      </rss>
      """

      {:ok, feed} = Parser.parse(xml)

      assert feed.title == "AI News Feed"
      assert length(feed.items) == 1

      item = hd(feed.items)
      assert item.title == "AI Reasoning Breakthrough"
      assert item.ai_model == ["Grok", "GPT"]
      assert item.ai_data_quality == 90
      assert item.json_ld != nil
      assert item.json_ld["headline"] == "AI Reasoning Breakthrough"

      # Use our filter features
      gpt_items = Rizz.filter_by_model([item], "GPT")
      assert length(gpt_items) == 1

      claude_items = Rizz.filter_by_model([item], "Claude")
      assert length(claude_items) == 0

      quality_items = Rizz.filter_by_quality([item], min_quality: 85)
      assert length(quality_items) == 1
    end
  end
end
