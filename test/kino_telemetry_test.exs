defmodule KinoTelemetryTest do
  use ExUnit.Case

  test "new/1 returns a KinoTelemetry for a LastValue metric" do
    last_value = Telemetry.Metrics.last_value([:a, :b, :c])
    kino = last_value |> KinoTelemetry.new()
    assert %KinoTelemetry{metric: ^last_value} = kino
  end

  test "KinoTelemetry.Render.to_livebook/1" do
    last_value = Telemetry.Metrics.last_value([:a, :b, :c])
    assert {:js, _} = last_value |> KinoTelemetry.new() |> Kino.Render.to_livebook()
  end
end
