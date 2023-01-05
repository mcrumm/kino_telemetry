defmodule KinoTelemetry.ProjectionTest do
  use ExUnit.Case, async: true

  doctest KinoTelemetry.Projection,
    import: KinoTelemetry.Projection

  describe "LastValue" do
    alias KinoTelemetry.LastValue

    test "init/1" do
      metric = Telemetry.Metrics.last_value("a.b.c")
      assert LastValue.init(metric) == :ok
    end

    test "handle_event/3" do
      metric = Telemetry.Metrics.last_value("a.b.c")
      state = metric |> LastValue.init()

      assert {[{nil, 123}], state} = LastValue.handle_data(123, %{}, metric, state)
      assert {[{nil, 456}], state} = LastValue.handle_data(456, %{}, metric, state)
      assert {[{nil, 789}], _state} = LastValue.handle_data(789, %{}, metric, state)
    end
  end

  describe "Counter" do
    alias KinoTelemetry.Counter

    test "init/1" do
      metric = Telemetry.Metrics.counter("a.b.c")
      assert Counter.init(metric) == %{}
    end

    test "handle_event/3" do
      metric = Telemetry.Metrics.last_value("a.b.c")
      state = metric |> Counter.init()

      assert {[{nil, 1}], state} = Counter.handle_data(0, %{}, metric, state)
      assert {[{nil, 2}], state} = Counter.handle_data(0, %{}, metric, state)
      assert {[{nil, 3}], _state} = Counter.handle_data(0, %{}, metric, state)
    end

    test "handle_event/3 with tags" do
      metric = Telemetry.Metrics.last_value("a.b.c", tags: [:a, :b])
      state = metric |> Counter.init()

      assert {[{nil, 1}], state} = Counter.handle_data(0, %{}, metric, state)
      assert {[{"C", 1}], state} = Counter.handle_data(0, %{a: "C"}, metric, state)
      assert {[{"D", 1}], state} = Counter.handle_data(0, %{a: "D"}, metric, state)

      assert {[{nil, 2}], state} = Counter.handle_data(0, %{}, metric, state)
      assert {[{"C", 2}], state} = Counter.handle_data(0, %{a: "C"}, metric, state)
      assert {[{"D", 2}], _state} = Counter.handle_data(0, %{a: "D"}, metric, state)
    end
  end

  describe "Sum" do
    alias KinoTelemetry.Sum

    test "init/1" do
      metric = Telemetry.Metrics.sum("a.b.c")
      assert Sum.init(metric) == %{}
    end

    test "handle_event/3" do
      metric = Telemetry.Metrics.last_value("a.b.c")
      state = metric |> Sum.init()

      assert {[{nil, 1}], state} = Sum.handle_data(1, %{}, metric, state)
      assert {[{nil, 3}], state} = Sum.handle_data(2, %{}, metric, state)
      assert {[{nil, 6}], _state} = Sum.handle_data(3, %{}, metric, state)
    end

    test "handle_event/3 with tags" do
      metric = Telemetry.Metrics.last_value("a.b.c", tags: [:a])
      state = metric |> Sum.init()

      assert {[{nil, 1}], state} = Sum.handle_data(1, %{}, metric, state)
      assert {[{"C", 1}], state} = Sum.handle_data(1, %{a: "C"}, metric, state)
      assert {[{"D", 1}], state} = Sum.handle_data(1, %{a: "D"}, metric, state)

      assert {[{nil, 2}], state} = Sum.handle_data(1, %{}, metric, state)
      assert {[{"C", 2}], state} = Sum.handle_data(1, %{a: "C"}, metric, state)
      assert {[{"D", 2}], _state} = Sum.handle_data(1, %{a: "D"}, metric, state)
    end
  end
end
