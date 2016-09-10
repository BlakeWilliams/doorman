defmodule Doorman.Mixfile do
  use Mix.Project

  def project do
    [app: :doorman,
     version: "0.5.0",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Tools to make Elixir authentication simple and flexible",
     package: package,
     docs: [extras: ["README.md"], main: "readme"],
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:plug, "~> 1.1.5"},
     {:comeonin, "~> 2.4.0"},
     {:ecto, "~> 2.0.0-rc.5", only: :test},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test"]
  defp elixirc_paths(_),     do: ["lib"]

  defp package do
    [
      name: :doorman,
      maintainers: ["Blake Williams", "Ashley Foster"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/BlakeWilliams/doorman"}
    ]
  end
end
