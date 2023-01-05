defmodule KinoTelemetry.LastValue do
  # Returns the last value received.
  @moduledoc false
  alias KinoTelemetry.Projection

  @behaviour Projection

  @impl true
  def init(_), do: :ok

  @impl true
  def handle_data(measurement, metadata, metric, state) do
    label = Projection.tags_to_label(metric, metadata)
    {[{label, measurement}], state}
  end
end
