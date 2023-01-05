defmodule KinoTelemetry.Sum do
  @moduledoc false
  alias KinoTelemetry.Projection

  @behaviour Projection

  @impl true
  def init(_), do: %{}

  @impl true
  def handle_data(measurement, metadata, metric, sums) do
    label = Projection.tags_to_label(metric, metadata)

    {value, new_sums} =
      Map.get_and_update(sums, label, fn sum ->
        new_sum = measurement + (sum || 0)
        {new_sum, new_sum}
      end)

    {[{label, value}], new_sums}
  end
end
