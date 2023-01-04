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

  def handle_metrics(_event_name, measurements, metadata, {chart, metric}) do
    time = System.system_time(:millisecond)

    if map = extract_datapoint_for_metric(metric, measurements, metadata, time) do
      %{label: label, measurement: measurement, time: time} = map
      Kino.VegaLite.push(chart, %{label: label, x: time, y: measurement})
    end

    :ok
  end

  defp extract_datapoint_for_metric(metric, measurements, metadata, time) do
    with true <- keep?(metric, metadata),
         measurement = extract_measurement(metric, measurements, metadata),
         true <- measurement != nil do
      label = tags_to_label(metric, metadata)
      %{label: label, measurement: measurement, time: time}
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

  defp tags_to_label(%{tags: []}, _metadata), do: nil

  defp tags_to_label(%{tags: tags, tag_values: tag_values}, metadata) do
    tag_values = tag_values.(metadata)

    tags
    |> Enum.reduce([], fn tag, acc ->
      case tag_values do
        %{^tag => value} -> [to_string(value) | acc]
        %{} -> acc
      end
    end)
    |> case do
      [] -> nil
      reversed_tags -> reversed_tags |> Enum.reduce(&[&1, " " | &2]) |> IO.iodata_to_binary()
    end
  end

  @impl true
  def init({parent, chart, metric}) do
    Process.flag(:trap_exit, true)
    ref = Process.monitor(parent)
    event_name = metric.event_name
    handler_id = {__MODULE__, event_name, self()}

    :telemetry.attach(handler_id, event_name, &__MODULE__.handle_metrics/4, {chart, metric})

    {:ok, %{ref: ref, handler_id: handler_id}}
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
end
