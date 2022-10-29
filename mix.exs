defmodule KinoTelemetry.MixProject do
  use Mix.Project

  @version "0.1.0"

  @source_url "https://github.com/mcrumm/kino_telemetry"

  def project do
    [
      app: :kino_telemetry,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      test_coverage: [summary: [threshold: 75]]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {KinoTelemetry.Application, []}
    ]
  end

  defp deps do
    [
      {:kino, "~> 0.7"},
      {:kino_vega_lite, "~> 0.1.5"},
      {:telemetry_metrics, "~> 0.6"},

      # Dev/Test dependencies
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp docs do
    [
      main: "components",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["guides/components.livemd"]
    ]
  end
end
