defmodule KinoTelemetry.Counter do
  @moduledoc false
  alias KinoTelemetry.Projection

  @behaviour Projection

  @impl true
  def init(_), do: %{}

  @impl true
  def handle_data(_measurement, metadata, metric, counts) do
    label = Projection.tags_to_label(metric, metadata)

    {value, new_counts} =
      Map.get_and_update(counts, label, fn count ->
        new_count = 1 + (count || 0)
        {new_count, new_count}
      end)

    {[{label, value}], new_counts}
  end
end
