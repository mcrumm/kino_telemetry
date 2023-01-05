defmodule KinoTelemetry.Listener do
  # Based on the PhoenixLiveDashboard Listener.
  # MIT License. Copyright (c) 2019 Michael Crumm, Chris McCord, José Valim.
  # https://github.com/phoenixframework/phoenix_live_dashboard/blob/0afa3af9be1be830d92c47191157fee303d79af9/lib/phoenix/live_dashboard/telemetry_listener.ex
  @moduledoc false
  use GenServer, restart: :temporary

  def listen(chart, metric) do
    DynamicSupervisor.start_child(
      KinoTelemetry.DynamicSupervisor,
      {__MODULE__, {self(), chart, metric}}
    )
  end

  def start_link({parent, chart, metric}) do
    GenServer.start_link(__MODULE__, {parent, chart, metric})
  end

  def handle_metrics(_event_name, measurements, metadata, {listener, ref, metric}) do
    time = System.system_time(:millisecond)

    if measurement = extract_measurement_for_metric(metric, measurements, metadata) do
      send(listener, {:telemetry, ref, time, measurement, metadata})
    end

    :ok
  end

  defp extract_measurement_for_metric(metric, measurements, metadata) do
    with true <- keep?(metric, metadata),
         measurement = extract_measurement(metric, measurements, metadata),
         true <- measurement != nil do
      measurement
    else
      _ -> nil
    end
  end

  defp keep?(%{keep: keep}, metadata) when keep != nil, do: keep.(metadata)
  defp keep?(_metric, _metadata), do: true

  defp extract_measurement(metric, measurements, metadata) do
    case metric.measurement do
      fun when is_function(fun, 2) -> fun.(measurements, metadata)
      fun when is_function(fun, 1) -> fun.(measurements)
      key -> measurements[key]
    end
  end

  @impl true
  def init({_parent, chart, metric}) do
    Process.flag(:trap_exit, true)
    ref = kino_js_live_monitor(chart)
    event_name = metric.event_name
    handler_id = {__MODULE__, event_name, self()}
    projection = projection(metric)
    acc = projection.init(metric)

    :telemetry.attach(handler_id, event_name, &__MODULE__.handle_metrics/4, {self(), ref, metric})

    {:ok,
     %{
       chart: chart,
       ref: ref,
       metric: metric,
       handler_id: handler_id,
       projection: projection,
       acc: acc
     }}
  end

  @impl true
  def handle_info({:telemetry, ref, time, measurement, metadata}, %{ref: ref} = state) do
    %{chart: chart, metric: metric, projection: projection, acc: acc} = state

    {pushes, new_acc} = projection.handle_data(measurement, metadata, metric, acc)

    data_points = Enum.map(pushes, fn {label, value} -> %{label: label, x: time, y: value} end)
    Kino.VegaLite.push_many(chart, data_points)

    {:noreply, %{state | acc: new_acc}}
  end

  @impl true
  def handle_info({:DOWN, ref, _, _, _}, %{ref: ref} = state) do
    {:stop, :shutdown, state}
  end

  @impl true
  def terminate(_reason, %{handler_id: handler_id}) do
    :telemetry.detach(handler_id)

    :ok
  end

  # Telemetry.Metrics.LastValue => KinoTelemetry.LastValue
  defp projection(%metric{}) do
    Module.concat(KinoTelemetry, metric |> Module.split() |> List.last())
  end

  defp kino_js_live_monitor(%Kino.JS.Live{} = live) do
    # Avoid dialyzer warnings re: opaque struct- we need to monitor
    # the live pid so we can terminate the listener on reevaulate.
    pid = apply(Map, :fetch!, [live, :pid])
    Process.monitor(pid)
  end
end
