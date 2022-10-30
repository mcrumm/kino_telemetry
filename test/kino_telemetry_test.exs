defmodule KinoTelemetryTest do
  use ExUnit.Case, async: true
  import Kino.Test

  setup :configure_livebook_bridge

  test "last_value spec" do
    kino = Telemetry.Metrics.last_value("a.b.c") |> KinoTelemetry.new()
    data = connect(kino.vl)
    assert %{spec: %{"mark" => %{"point" => true, "type" => "line"}}} = data
  end

  test "pushes measurements after initial connection" do
    last_value = Telemetry.Metrics.last_value("a.b.c")
    kino = last_value |> KinoTelemetry.new() |> Kino.render()
    assert %KinoTelemetry{metric: ^last_value} = kino

    :telemetry.execute([:a, :b], %{c: 123}, %{})

    data = connect(kino.vl)
    assert %{spec: %{}, datasets: [[nil, [%{x: x, y: 123}]]]} = data
    assert_in_delta(x, System.system_time(:millisecond), 5)
  end

  test "only pushes measurements to keep" do
    last_value = Telemetry.Metrics.last_value("a.b.c", keep: & &1.keep?)
    kino = last_value |> KinoTelemetry.new() |> Kino.render()

    :telemetry.execute([:a, :b], %{c: 200}, %{keep?: false})
    :telemetry.execute([:a, :b], %{c: 100}, %{keep?: true})

    data = connect(kino.vl)
    assert %{spec: %{}, datasets: [[nil, [%{x: _, y: 100}]]]} = data
  end
end
