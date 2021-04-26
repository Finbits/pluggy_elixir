defmodule PluggyElixir.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Plug.Conn
      import PluggyElixir.BypassExpect

      def create_and_save_api_key do
        auth = %PluggyElixir.Auth{api_key: "generated_api_key_#{:rand.uniform()}"}
        PluggyElixir.Auth.Guard.set_auth(auth)

        auth.api_key
      end
    end
  end

  setup _tags do
    bypass = Bypass.open(port: Application.fetch_env!(:bypass, :port))

    {:ok, bypass: bypass}
  end
end
