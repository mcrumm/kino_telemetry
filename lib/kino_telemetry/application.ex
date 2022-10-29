defmodule KinoTelemetry.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: KinoTelemetry.DynamicSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: KinoTelemetry.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
