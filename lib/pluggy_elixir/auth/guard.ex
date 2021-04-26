defmodule PluggyElixir.Auth.Guard do
  @moduledoc false
  use Agent

  @env Mix.env()

  alias PluggyElixir.{Auth, Error}

  @spec start_link(map()) :: {:ok, pid()} | {:error, any()}
  def start_link(initial_value \\ %{}) when is_map(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  @spec get_auth :: Auth.t() | Error.t()
  def get_auth do
    __MODULE__
    |> Agent.get(& &1)
    |> Map.get(registry_key(@env))
  end

  defdelegate set_auth_error(error), to: __MODULE__, as: :set_auth

  @spec set_auth(Auth.t() | Error.t()) :: :ok
  def set_auth(auth) do
    key = registry_key(@env)

    Agent.update(__MODULE__, fn state -> Map.put(state, key, auth) end)
  end

  defp remove_auth(pid) do
    Agent.update(__MODULE__, fn state -> Map.delete(state, inspect(pid)) end)
  end

  defp registry_key(:test) do
    monitor_process()

    inspect(self())
  end

  defp registry_key(_env), do: :auth

  defp monitor_process do
    pid = self()

    spawn(fn ->
      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, :process, ^pid, _reason} -> remove_auth(pid)
        _any -> :ok
      end
    end)
  end
end
