# Rizz

An Elixir package for working with RSS Information Zone Zapper (RIZZ) feeds - the standard for AI-ready content feeds.

[![Hex.pm](https://img.shields.io/hexpm/v/rizz.svg)](https://hex.pm/packages/rizz)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/rizz)

## What is RIZZ?

RIZZ (RSS Information Zone Zapper) is a specification for AI-optimized RSS feeds. It extends standard RSS 2.0 with AI-specific metadata using XML namespaces to make content easily consumable by AI models.

RIZZ adds:
- AI model compatibility information
- Context/prompt guidance for AI
- Data quality scores
- Optional JSON-LD semantic data

## Installation

Add `rizz` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rizz, "~> 0.1.0"}
  ]
end
```

## Usage

### Fetching a RIZZ Feed

```elixir
# Fetch a RIZZ feed
{:ok, feed} = Rizz.fetch("https://example.com/feed.xml")

# Fetch with authentication
{:ok, feed} = Rizz.fetch("https://example.com/feed.xml", 
  headers: [{"Authorization", "Bearer your-token-here"}])
```

### Parsing RIZZ XML

```elixir
# Parse RIZZ XML content
xml_content = File.read!("feed.xml")
{:ok, feed} = Rizz.parse(xml_content)
```

### Working with Feed Entries

```elixir
# Filter entries by AI model compatibility
gpt_feed = Rizz.filter_by_model(feed, "GPT")

# Filter entries by minimum data quality score
high_quality_feed = Rizz.filter_by_quality(feed, min_quality: 80)

# Get AI metadata from entries
Enum.each(feed.entries, fn entry ->
  title = entry.title
  url = entry.url
  models = Rizz.get_ai_models(entry)
  context = Rizz.get_ai_context(entry)
  quality = Rizz.get_data_quality(entry)
  json_ld = Rizz.get_json_ld(entry)
  
  # Process entry with AI metadata
  IO.puts("Processing: #{title} with models: #{inspect(models)}")
end)
```

## Command-Line Interface

The package includes a command-line interface for working with RIZZ feeds:

```bash
# Build the escript
mix escript.build

# Fetch a feed
./rizz fetch https://example.com/feed.xml

# Filter by model
./rizz fetch https://example.com/feed.xml --model GPT

# Filter by quality
./rizz fetch https://example.com/feed.xml --quality 80

# Use authentication
./rizz fetch https://example.com/feed.xml --headers "Authorization:Bearer token"

# Save output to file
./rizz fetch https://example.com/feed.xml -m GPT -q 80 -o feed.txt

# Get help
./rizz help
```

## RIZZ Specification

RIZZ extends standard RSS 2.0 with AI-specific namespaced elements:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:ai="http://xai.org/RIZZ-namespace">
  <channel>
    <title>AI News Feed</title>
    <link>https://example.com/ai-news</link>
    <description>AI updates for bots</description>
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
        "description": "New AI logic techniques."
      }
      </script>
    </item>
  </channel>
</rss>
```

### AI-Specific Elements

- `<ai:model>`: Compatible AI models (e.g., `Grok, GPT`)
- `<ai:context>`: AI prompt or context (e.g., `Summarize for developers`)
- `<ai:dataQuality>`: Data quality score (0-100)
- Optional JSON-LD in `<script type="application/ld+json">` tags

## Related Resources

- [RIZZ Specification](https://github.com/agnt-gg/rizz)
- [Elixir Feed Parser](https://github.com/avencera/elixir_feed_parser)

## License

MIT

