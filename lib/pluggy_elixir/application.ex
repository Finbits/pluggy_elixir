defmodule PluggyElixir.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {PluggyElixir.Auth.Guard, %{}}
    ]

    opts = [strategy: :one_for_one, name: PluggyElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
