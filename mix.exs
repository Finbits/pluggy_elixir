defmodule PluggyElixir.MixProject do
  use Mix.Project

  @version "0.0.1"
  @description "A client library for Pluggy.ai API"
  @links %{"GitHub" => "https://github.com/brainnco/pluggy_elixir"}

  def project do
    [
      app: :pluggy_elixir,
      version: @version,
      description: @description,
      source_url: @links["GitHub"],
      package: package(),
      docs: docs(),
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.json": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger],
      mod: {PluggyElixir.Application, []}
    ]
  end

  defp deps do
    [
      # Dev/Test dependencies
      {:credo, "~> 1.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: @links
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md": [title: "Get starting"]
      ],
      groups_for_modules: []
    ]
  end
end
