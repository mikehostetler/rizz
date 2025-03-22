defmodule Rizz.ParserTest do
  use ExUnit.Case

  alias Rizz.Parser

  describe "parse/1" do
    test "parses a basic RIZZ feed" do
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
            <description>New models</description>
            <pubDate>Mon, 01 Jan 2023 12:00:00 GMT</pubDate>
            <ai:model>GPT, Grok</ai:model>
            <ai:context>Summarize for developers</ai:context>
            <ai:dataQuality>85</ai:dataQuality>
          </item>
        </channel>
      </rss>
      """

      {:ok, feed} = Parser.parse(xml)

      assert feed.title == "AI News Feed"
      assert feed.link == "https://example.com/ai-news"
      assert feed.description == "AI updates for bots"
      assert length(feed.items) == 1

      item = hd(feed.items)
      assert item.title == "AI Update"
      assert item.link == "https://example.com/update"
      assert item.description == "New models"
      assert item.ai_model == ["GPT", "Grok"]
      assert item.ai_context == "Summarize for developers"
      assert item.ai_data_quality == 85
    end

    test "parses a feed with JSON-LD" do
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

      {:ok, feed} = Parser.parse(xml)

      assert length(feed.items) == 1
      item = hd(feed.items)

      assert item.json_ld != nil
      assert item.json_ld["@context"] == "https://schema.org"
      assert item.json_ld["@type"] == "Article"
      assert item.json_ld["headline"] == "AI Update"
      assert item.json_ld["url"] == "https://example.com/update"
    end

    test "handles invalid XML" do
      xml = """
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Incomplete feed
      """

      result = Parser.parse(xml)
      assert match?({:error, _}, result)
    end
  end
end
