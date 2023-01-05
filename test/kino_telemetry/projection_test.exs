defmodule KinoTelemetry.ProjectionTest do
  use ExUnit.Case, async: true

  alias KinoTelemetry.Projection

  doctest Projection, import: Projection

  test "LastValue" do
    metric = Telemetry.Metrics.last_value("a.b.c")
    assert {[{nil, 123}], state} = Projection.project(123, %{}, metric, %{})
    assert {[{nil, 456}], state} = Projection.project(456, %{}, metric, state)
    assert {[{nil, 789}], _state} = Projection.project(789, %{}, metric, state)

    metric = Telemetry.Metrics.last_value("a.b.c", tags: [:a, :b])
    assert {[{nil, 1}], state} = Projection.project(1, %{}, metric, %{})
    assert {[{"C", 2}], state} = Projection.project(2, %{a: "C"}, metric, state)
    assert {[{"D", 3}], state} = Projection.project(3, %{a: "D"}, metric, state)
    assert {[{nil, 4}], state} = Projection.project(4, %{}, metric, state)
    assert {[{"C", 5}], state} = Projection.project(5, %{a: "C"}, metric, state)
    assert {[{"D", 6}], _state} = Projection.project(6, %{a: "D"}, metric, state)
  end

  test "Counter" do
    metric = Telemetry.Metrics.counter("a.b.c")
    assert {[{nil, 1}], state} = Projection.project(0, %{}, metric, %{})
    assert {[{nil, 2}], state} = Projection.project(0, %{}, metric, state)
    assert {[{nil, 3}], _state} = Projection.project(0, %{}, metric, state)

    metric = Telemetry.Metrics.counter("a.b.c", tags: [:a, :b])
    assert {[{nil, 1}], state} = Projection.project(0, %{}, metric, %{})
    assert {[{"C", 1}], state} = Projection.project(0, %{a: "C"}, metric, state)
    assert {[{"D", 1}], state} = Projection.project(0, %{a: "D"}, metric, state)
    assert {[{nil, 2}], state} = Projection.project(0, %{}, metric, state)
    assert {[{"C", 2}], state} = Projection.project(0, %{a: "C"}, metric, state)
    assert {[{"D", 2}], _state} = Projection.project(0, %{a: "D"}, metric, state)
  end

  test "Sum" do
    metric = Telemetry.Metrics.sum("a.b.c")
    assert {[{nil, 1}], state} = Projection.project(1, %{}, metric, %{})
    assert {[{nil, 2}], state} = Projection.project(1, %{}, metric, state)
    assert {[{nil, 3}], _state} = Projection.project(1, %{}, metric, state)

    metric = Telemetry.Metrics.sum("a.b.c", tags: [:a, :b])
    assert {[{nil, 1}], state} = Projection.project(1, %{}, metric, %{})
    assert {[{"C", 2}], state} = Projection.project(2, %{a: "C"}, metric, state)
    assert {[{"D", 3}], state} = Projection.project(3, %{a: "D"}, metric, state)
    assert {[{nil, 5}], state} = Projection.project(4, %{}, metric, state)
    assert {[{"C", 7}], state} = Projection.project(5, %{a: "C"}, metric, state)
    assert {[{"D", 9}], _state} = Projection.project(6, %{a: "D"}, metric, state)
  end
end
