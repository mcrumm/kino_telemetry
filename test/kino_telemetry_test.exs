defmodule KinoTelemetryTest do
  use ExUnit.Case, async: true
  import Kino.Test

  setup :configure_livebook_bridge

  test "last_value spec", c do
    kino = Telemetry.Metrics.last_value("test.#{c.test}.value") |> KinoTelemetry.new()
    data = connect(kino.vl)
    assert %{spec: %{"mark" => %{"point" => true, "type" => "line"}}} = data
  end

  test "pushes measurements after initial connection", c do
    last_value = Telemetry.Metrics.last_value("test.#{c.test}.value")
    kino = last_value |> KinoTelemetry.new() |> Kino.render()
    assert %KinoTelemetry{metric: ^last_value} = kino

    :telemetry.execute([:test, c.test], %{value: 123}, %{})

    Process.sleep(1)
    data = connect(kino.vl)
    assert %{spec: %{}, datasets: [[nil, [%{x: x, y: 123}]]]} = data
    assert_in_delta(x, System.system_time(:millisecond), 5)
  end

  test "only pushes measurements to keep", c do
    last_value = Telemetry.Metrics.last_value("test.#{c.test}.value", keep: & &1.keep?)
    kino = last_value |> KinoTelemetry.new() |> Kino.render()

    :telemetry.execute([:test, c.test], %{value: 200}, %{keep?: false})
    :telemetry.execute([:test, c.test], %{value: 100}, %{keep?: true})

    Process.sleep(1)
    data = connect(kino.vl)
    assert %{spec: %{}, datasets: [[nil, [%{x: _, y: 100}]]]} = data
  end

  test "pushes tagged measurements", c do
    last_value = Telemetry.Metrics.last_value("test.#{c.test}.value", tags: [:tag])
    kino = last_value |> KinoTelemetry.new() |> Kino.render()

    :telemetry.execute([:test, c.test], %{value: 100}, %{tag: "b"})
    :telemetry.execute([:test, c.test], %{value: 100}, %{tag: "a"})

    Process.sleep(1)
    data = connect(kino.vl)

    assert %{
             spec: %{},
             datasets: [
               [
                 nil,
                 [
                   %{label: "b", x: _, y: 100},
                   %{label: "a", x: _, y: 100}
                 ]
               ]
             ]
           } = data
  end
end
