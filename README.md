# Rizz

An Elixir package for working with RSS Information Zone Zapper (RIZZ) feeds - the standard for AI-ready content feeds.

## Installation

Add `rizz` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rizz, "~> 0.1.0"}
  ]
end
```

## About RIZZ

RIZZ (RSS Information Zone Zapper) is a specification for AI-optimized RSS feeds. It extends standard RSS 2.0 with AI-specific metadata using XML namespaces.

Key features:
- Based on standard RSS 2.0 XML
- Uses AI namespace for metadata about model compatibility, context, and data quality
- Optional JSON-LD support for enhanced semantic data

## Usage

### Fetching a RIZZ Feed

```elixir
# Fetch a RIZZ feed
{:ok, feed} = Rizz.fetch("https://example.com/RIZZ.xml")

# Fetch with authentication
{:ok, feed} = Rizz.fetch("https://example.com/RIZZ.xml", 
  headers: [{"Authorization", "Bearer your-token-here"}])
```

### Processing Feed Items

```elixir
# Get all items
items = Rizz.get_items(feed)

# Filter items by AI model compatibility
gpt_items = Rizz.filter_by_model(items, "GPT")

# Get items with high data quality
quality_items = Rizz.filter_by_quality(items, min_quality: 80)

# Process each item
Enum.each(items, fn item ->
  title = Rizz.get_title(item)
  description = Rizz.get_description(item)
  ai_context = Rizz.get_ai_context(item)
  
  IO.puts("Processing: #{title} with context: #{ai_context}")
end)
```

### Creating a RIZZ Feed

```elixir
# Create a new feed
feed = Rizz.new_feed(
  title: "AI News Feed",
  link: "https://example.com/ai-news",
  description: "AI updates for bots"
)

# Add an item with AI metadata
feed = Rizz.add_item(feed, %{
  title: "AI Reasoning Breakthrough",
  link: "https://example.com/news/reasoning",
  description: "New AI logic techniques.",
  pub_date: ~U[2025-03-10 01:45:00Z],
  ai_model: ["Grok", "GPT"],
  ai_context: "Summarize for developers",
  ai_data_quality: 90,
  json_ld: %{
    "@context" => "https://schema.org",
    "@type" => "Article",
    "headline" => "AI Reasoning Breakthrough",
    # ...additional JSON-LD data
  }
})

# Generate XML
xml = Rizz.to_xml(feed)
```

## Features

- Fetching and parsing RIZZ feeds
- Creating and generating RIZZ-compliant XML
- Filtering feed items by AI metadata (model, context, quality)
- Support for JSON-LD semantic data
- Support for authentication (Basic, Bearer tokens)

## License

MIT

