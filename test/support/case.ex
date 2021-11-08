defmodule PluggyElixir.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Plug.Conn
      import PluggyElixir.Test
    end
  end

  setup _tags do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end
end
