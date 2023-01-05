defmodule KinoTelemetry.Projection do
  # Generic behaviour for transforming telemetry events for display.
  @moduledoc false

  @type measurement :: number()

  @type metadata :: :telemetry.event_metadata()

  @type metric :: Telemetry.Metrics.t()

  @type state :: term()

  @type label :: nil | String.t()

  @type label_value :: {label, number()}

  @doc """
  Initializes state for the projection.
  """
  @callback init(metric) :: state

  @doc """
  Returns the next chart datapoint.
  """
  @callback handle_data(measurement, metadata, metric, state) ::
              {[label_value], new_state :: term()}

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
  @spec tags_to_label(metric, map) :: label
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
