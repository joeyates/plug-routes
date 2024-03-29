defmodule Plug.Routes.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plug_routes,
      version: "0.0.2",
      elixir: "~> 1.0",
      deps: deps
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:beam_analyzer, ">= 0.0.3"},
      {:plug, "~> 0.13.0 or ~> 1.0.0"},
    ]
  end
end
