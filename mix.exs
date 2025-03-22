defmodule Rizz.MixProject do
  use Mix.Project

  def project do
    [
      app: :rizz,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "RSS Information Zone Zapper (RIZZ) - A package for AI-ready RSS feeds",
      package: package(),
      name: "Rizz",
      source_url: "https://github.com/mikehostetler/rizz",
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_feed_parser, "~> 2.1"},  # Base RSS/Atom parsing
      {:req, "~> 0.4.0"},               # HTTP client
      {:jason, "~> 1.4"},               # JSON parsing for JSON-LD
      {:timex, "~> 3.7"},               # DateTime handling
      {:sweet_xml, "~> 0.7"},           # XML extensions for AI metadata
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}  # Documentation
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mikehostetler/rizz"}
    ]
  end

  defp escript do
    [
      main_module: Rizz.CLI,
      name: "rizz"
    ]
  end
end
