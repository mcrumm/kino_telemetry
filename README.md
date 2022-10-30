# KinoTelemetry

Renders [Telemetry.Metrics](https://github.com/beam-telemetry/telemetry_metrics) definitions in [Livebook](https://livebook.dev).

<img width="917" alt="Screen Shot of Telemetry Metrics in Livebook" src="https://user-images.githubusercontent.com/168677/198905630-78575011-d23f-4b54-9af9-de3e114e2f1d.png">

## Usage

```elixir
Mix.install([
  {:kino_telemetry, github: "mcrumm/kino_telemetry"},
  {:telemetry_poller, "~> 1.0"}
])

{:ok, _} = :telemetry_poller.start_link(measurements: [], period: 5_000)

Telemetry.Metrics.last_value("vm.memory.binary", unit: :byte)
|> KinoTelemetry.Metric.new()
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kino_telemetry` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kino_telemetry, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/kino_telemetry>.

