defmodule KinoTelemetryTest do
  use ExUnit.Case, async: true
  import Kino.Test

  setup :configure_livebook_bridge

  test "sends telemetry events after initial connection" do
    last_value = Telemetry.Metrics.last_value("a.b.c")
    kino = last_value |> KinoTelemetry.new() |> Kino.render()
    assert %KinoTelemetry{metric: ^last_value} = kino

    :telemetry.execute([:a, :b], %{c: 123}, %{})

    data = connect(kino.vl)
    assert %{spec: %{}, datasets: [[nil, [%{x: x, y: 123}]]]} = data
    assert_in_delta(x, System.system_time(:microsecond), 5_000)
  end
end
