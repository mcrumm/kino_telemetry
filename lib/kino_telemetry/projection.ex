defmodule KinoTelemetry.Projection do
  # Generic behaviour for transforming telemetry events for display.
  @moduledoc false

  @doc """
  Performs a projection on the given `measurement` for the given `metric`.
  """
  @spec project(number(), :telemetry.event_metadata(), Telemetry.Metrics.t(), map) ::
          {[{String.t(), number()}], new_state :: term()}
  def project(measurement, metadata, %struct{} = metric, acc) do
    label = tags_to_label(metric, metadata)

    case struct do
      Telemetry.Metrics.LastValue ->
        {[{label, measurement}], acc}

      Telemetry.Metrics.Counter ->
        {value, new_counts} =
          Map.get_and_update(acc, label, fn count ->
            new_count = 1 + (count || 0)
            {new_count, new_count}
          end)

        {[{label, value}], new_counts}

      Telemetry.Metrics.Sum ->
        {value, new_sums} =
          Map.get_and_update(acc, label, fn sum ->
            new_sum = measurement + (sum || 0)
            {new_sum, new_sum}
          end)

        {[{label, value}], new_sums}
    end
  end

  @doc """
  Returns a string representation of the tag values for the given metric.

  ## Examples

      iex> Telemetry.Metrics.last_value("a.b.c") |> tags_to_label(%{})
      nil

      iex> Telemetry.Metrics.last_value("a.b.c") |> tags_to_label(%{foo: "bar"})
      nil

      iex> Telemetry.Metrics.last_value("a.b.c", tags: [:foo]) |> tags_to_label(%{})
      nil

      iex> Telemetry.Metrics.last_value("a.b.c", tags: [:foo]) |> tags_to_label(%{foo: "foo"})
      "foo"

      iex> Telemetry.Metrics.last_value("a.b.c", tags: [:foo, :bar]) |> tags_to_label(%{foo: "foo", bar: "bar"})
      "foo bar"

  """
  @spec tags_to_label(Telemetry.Metrics.t(), map) :: nil | String.t()
  def tags_to_label(metric, metadata)

  def tags_to_label(%{tags: []}, _metadata), do: nil

  def tags_to_label(%{tags: tags, tag_values: tag_values}, metadata) do
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
end
