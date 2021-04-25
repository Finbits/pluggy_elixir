defmodule PluggyElixir.AuthTest do
  use PluggyElixir.Case, async: false

  alias PluggyElixir.Auth
  alias PluggyElixir.Error.Unauthorized

  setup do
    config = Application.get_all_env(:pluggy_elixir)

    on_exit(fn ->
      Application.put_all_env(pluggy_elixir: config)
    end)

    :ok
  end

  describe "create_api_key/0" do
    test "return a api_key", %{bypass: bypass} do
      bypass_expect(bypass, "POST", "/auth", fn conn ->
        assert %{
                 "clientId" => _client_id,
                 "clientSecret" => _client_secret,
                 "nonExpiring" => _expiring
               } = conn.body_params

        Conn.resp(conn, 200, ~s<{"apiKey": "valid-api-key"}>)
      end)

      assert Auth.create_api_key() == {:ok, %Auth{api_key: "valid-api-key"}}
    end

    test "send nonExpiring param as true when configured", %{bypass: bypass} do
      Application.put_env(:pluggy_elixir, :non_expiring_api_key, true)

      bypass_expect(bypass, "POST", "/auth", fn conn ->
        assert %{"nonExpiring" => true} = conn.body_params

        Conn.resp(conn, 200, ~s<{"apiKey": "valid-api-key"}>)
      end)

      assert Auth.create_api_key() == {:ok, %Auth{api_key: "valid-api-key"}}
    end

    test "return an error when client_id configuration is missing" do
      Application.delete_env(:pluggy_elixir, :client_id)

      assert Auth.create_api_key() ==
               {:error, "Missing PluggyElixir configuration: [ client_id ]"}
    end

    test "return an error when client_secret configuration is missing" do
      Application.delete_env(:pluggy_elixir, :client_secret)

      assert Auth.create_api_key() ==
               {:error, "Missing PluggyElixir configuration: [ client_secret ]"}
    end

    test "return an unauthorized error", %{bypass: bypass} do
      bypass_expect(bypass, "POST", "/auth", fn conn ->
        Conn.resp(conn, 401, ~s<{"message":"Client keys are invalid","code":401}>)
      end)

      assert Auth.create_api_key() == {:error, %Unauthorized{message: "Client keys are invalid"}}
    end
  end
end
