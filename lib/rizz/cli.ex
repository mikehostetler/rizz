defmodule Rizz.CLI do
  @moduledoc """
  Command-line interface for working with RIZZ feeds.
  """

  @doc """
  Main entry point for the CLI.
  """
  def main(args) do
    {opts, cmds, _} = OptionParser.parse(args,
      switches: [
        model: :string,
        quality: :integer,
        headers: :string,
        output: :string
      ],
      aliases: [
        m: :model,
        q: :quality,
        o: :output
      ]
    )

    command = List.first(cmds) || "help"

    case command do
      "fetch" ->
        url = Enum.at(cmds, 1)
        if url do
          fetch_command(url, opts)
        else
          IO.puts("Error: URL required for fetch command")
          display_help()
        end

      "help" ->
        display_help()

      _ ->
        IO.puts("Unknown command: #{command}")
        display_help()
    end
  end

  @doc """
  Fetch a RIZZ feed and display its contents.
  """
  def fetch_command(url, opts) do
    headers =
      case Keyword.get(opts, :headers) do
        nil -> []
        headers_str ->
          headers_str
          |> String.split(",")
          |> Enum.map(fn header ->
            [key, value] = String.split(header, ":", parts: 2)
            {String.trim(key), String.trim(value)}
          end)
      end

    fetch_opts = [headers: headers]

    case Rizz.fetch(url, fetch_opts) do
      {:ok, feed} ->
        # Apply filters if specified
        feed =
          case Keyword.get(opts, :model) do
            nil -> feed
            model -> Rizz.filter_by_model(feed, model)
          end

        feed =
          case Keyword.get(opts, :quality) do
            nil -> feed
            quality -> Rizz.filter_by_quality(feed, min_quality: quality)
          end

        # Display feed information
        display_feed(feed, opts)

      {:error, reason} ->
        IO.puts("Error fetching feed: #{inspect(reason)}")
    end
  end

  @doc """
  Display feed contents.
  """
  def display_feed(feed, opts) do
    IO.puts("Feed: #{feed.title}")
    IO.puts("URL: #{feed.url}")
    IO.puts("Description: #{feed.subtitle}")
    IO.puts("Entries: #{length(feed.entries)}")

    Enum.each(feed.entries, fn entry ->
      IO.puts("\n-- Entry: #{entry.title} --")
      IO.puts("URL: #{entry.url}")

      if entry.ai_models do
        IO.puts("AI Models: #{Enum.join(entry.ai_models, ", ")}")
      end

      if entry.ai_context do
        IO.puts("AI Context: #{entry.ai_context}")
      end

      if entry.ai_data_quality do
        IO.puts("Data Quality: #{entry.ai_data_quality}")
      end

      if entry.json_ld do
        IO.puts("JSON-LD: #{inspect(entry.json_ld, pretty: true)}")
      end
    end)

    # Output to file if specified
    case Keyword.get(opts, :output) do
      nil -> :ok
      file ->
        output = inspect(feed, pretty: true)
        File.write!(file, output)
        IO.puts("\nOutput written to #{file}")
    end
  end

  @doc """
  Display help information.
  """
  def display_help do
    IO.puts("""

    RIZZ - RSS Information Zone Zapper CLI

    Usage:
      rizz fetch URL [options]
      rizz help

    Options:
      -m, --model   Filter entries by AI model compatibility
      -q, --quality Filter entries by minimum data quality (0-100)
      --headers     HTTP headers as "Key1:Value1,Key2:Value2"
      -o, --output  Write output to file

    Examples:
      rizz fetch https://example.com/feed.xml
      rizz fetch https://example.com/feed.xml --model GPT
      rizz fetch https://example.com/feed.xml --quality 80
      rizz fetch https://example.com/feed.xml --headers "Authorization:Bearer token"
      rizz fetch https://example.com/feed.xml -m GPT -q 80 -o feed.txt

    """)
  end
end
