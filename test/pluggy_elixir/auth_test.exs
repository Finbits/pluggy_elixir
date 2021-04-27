defmodule PluggyElixir.AuthTest do
  use PluggyElixir.Case, async: true

  alias PluggyElixir.Auth
  alias PluggyElixir.HttpClient.Error

  describe "create_api_key/1" do
    test "return a api_key", %{bypass: bypass} do
      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "POST", "/auth", fn conn ->
        assert %{
                 "clientId" => _client_id,
                 "clientSecret" => _client_secret,
                 "nonExpiring" => _expiring
               } = conn.body_params

        Conn.resp(conn, 200, ~s<{"apiKey": "valid-api-key"}>)
      end)

      assert Auth.create_api_key(config_overrides) == {:ok, %Auth{api_key: "valid-api-key"}}
    end

    test "send nonExpiring param as true when configured", %{bypass: bypass} do
      config_overrides = [host: "http://localhost:#{bypass.port}", non_expiring_api_key: true]

      bypass_expect(bypass, "POST", "/auth", fn conn ->
        assert %{"nonExpiring" => true} = conn.body_params

        Conn.resp(conn, 200, ~s<{"apiKey": "valid-api-key"}>)
      end)

      assert Auth.create_api_key(config_overrides) == {:ok, %Auth{api_key: "valid-api-key"}}
    end

    test "return an unauthorized error", %{bypass: bypass} do
      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "POST", "/auth", fn conn ->
        Conn.resp(conn, 401, ~s<{"message":"Client keys are invalid","code":401}>)
      end)

      assert Auth.create_api_key(config_overrides) ==
               {:error, %Error{message: "Client keys are invalid", code: 401}}
    end
  end
end
