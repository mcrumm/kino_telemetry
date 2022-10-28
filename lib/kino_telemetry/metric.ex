defmodule KinoTelemetry.Metric do
  @moduledoc """
  Component that renders a Telemetry.Metric definition as a cell.
  """
  alias VegaLite, as: Vl

  defstruct [:metric, :pid, :vl]

  @doc """
  Creates a new kino with the given `Telemetry.Metrics` definition.
  """
  def new(metric) when is_struct(metric, Telemetry.Metrics.LastValue) do
    chart_options = chart_options(metric)

    chart =
      Vl.new(chart_options)
      |> Vl.mark(:line)
      |> Vl.encode_field(:x, "x", type: :quantitative)
      |> Vl.encode_field(:y, "y", type: :quantitative)
      |> Kino.VegaLite.new()

    {:ok, pid} = KinoTelemetry.Listener.listen([{chart, metric}])

    %__MODULE__{metric: metric, vl: chart, pid: pid}
  end

  defp chart_options(%{reporter_options: options}) do
    options
    |> Keyword.take([:width, :height])
    |> Keyword.put_new(:width, 400)
    |> Keyword.put_new(:height, 400)
  end

  defimpl Kino.Render do
    def to_livebook(chart) do
      Kino.Render.to_livebook(chart.vl)
    end
  end
end
