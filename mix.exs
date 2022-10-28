defmodule KinoTelemetry.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :kino_telemetry,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:telemetry_metrics, "~> 0.6"}
    ]
  end
end
