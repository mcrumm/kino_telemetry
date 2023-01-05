defmodule KinoTelemetry do
  @moduledoc """
  A kino wrapping a `Telemetry.Metrics` definition.
  """
  alias VegaLite, as: Vl

  defstruct [:metric, :pid, :vl]

  @doc """
  Creates a new kino with the given `Telemetry.Metrics` definition.
  """
  def new(metric)
      when is_struct(metric, Telemetry.Metrics.LastValue) or
             is_struct(metric, Telemetry.Metrics.Counter) or
             is_struct(metric, Telemetry.Metrics.Sum) do
    chart_options = chart_options(metric)

    chart =
      Vl.new(chart_options)
      |> Vl.mark(:line, point: true)
      |> Vl.encode_field(:x, "x", title: "Time", type: :temporal)
      |> Vl.encode_field(:y, "y", title: chart_label(metric), type: :quantitative)
      |> encode_tag_field(metric.__struct__, metric.tags)
      |> Kino.VegaLite.new()

    {:ok, pid} = KinoTelemetry.Listener.listen(chart, metric)

    %__MODULE__{metric: metric, vl: chart, pid: pid}
  end

  def new(metric) when is_struct(metric, Telemetry.Metrics.Summary) do
    raise ArgumentError, "Summary metrics are not supported"
  end

  def new(metric) when is_struct(metric, Telemetry.Metrics.Distribution) do
    raise ArgumentError, "Distribution metrics are not supported"
  end

  defp encode_tag_field(chart, _, []), do: chart

  defp encode_tag_field(chart, _, tags) do
    title = Enum.join(tags, "-")
    Vl.encode_field(chart, :color, "label", title: title, type: :nominal)
  end

  defp chart_options(%{reporter_options: options}) do
    options
    |> Keyword.take([:width, :height])
    |> Keyword.put_new(:width, 400)
    |> Keyword.put_new(:height, 400)
  end

  defp chart_label(%{name: name}) do
    name |> List.last() |> humanize()
  end

  # Humanizes a module or field name.
  # Phoenix Framework. MIT License. Copyright (c) 2014 Chris McCord.
  # https://github.com/phoenixframework/phoenix/blob/d488e2b60b74a98459cf117ae40ba013debc4807/lib/phoenix/naming.ex#L120-L131
  defp humanize(atom) when is_atom(atom),
    do: humanize(Atom.to_string(atom))

  defp humanize(bin) when is_binary(bin) do
    bin =
      if String.ends_with?(bin, "_id") do
        binary_part(bin, 0, byte_size(bin) - 3)
      else
        bin
      end

    bin |> String.replace("_", " ") |> String.capitalize()
  end

  defimpl Kino.Render do
    def to_livebook(chart) do
      Kino.Render.to_livebook(chart.vl)
    end
  end
end
