defmodule PluggyElixir.HttpClientTest do
  use PluggyElixir.Case, async: false

  alias PluggyElixir.{Auth, Config, HttpClient}
  alias PluggyElixir.Auth.Guard
  alias PluggyElixir.HttpAdapter.Response
  alias PluggyElixir.HttpClient.Error

  describe "[ authentication flow ]" do
    test "create api token when there inst and make get request", %{bypass: bypass} do
      url = "/transactions"
      created_api_key = "http-client-valid-api-key-001"

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "POST", "auth", fn conn ->
        Conn.resp(conn, 200, ~s<{"apiKey": "#{created_api_key}"}>)
      end)

      bypass_expect(bypass, "GET", url, fn conn ->
        assert Enum.any?(conn.req_headers, fn header ->
                 header == {"x-api-key", created_api_key}
               end)

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      response = HttpClient.get(url, config_overrides)

      assert {:ok, %Response{}} = response

      assert Enum.any?(:sys.get_state(Guard), fn {_key, %{api_key: value}} ->
               value == created_api_key
             end)
    end

    test "reutrn unauthorized error when try to create api token", %{bypass: bypass} do
      url = "/transactions"

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "POST", "auth", fn conn ->
        Conn.resp(conn, 401, ~s<{"message":"Client keys are invalid","code":401}>)
      end)

      response = HttpClient.get(url, config_overrides)

      assert {:error, %Error{} = error} = response

      pid = inspect(self())

      assert Enum.any?(:sys.get_state(Guard), fn {key, value} ->
               key == pid and value == error
             end)
    end

    test "use preseted api key", %{bypass: bypass} do
      url = "/transactions"
      created_api_key = "http-client-valid-api-key-002"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      Guard.set_auth(%Auth{api_key: created_api_key})

      bypass_expect(bypass, "GET", url, fn conn ->
        assert Enum.any?(conn.req_headers, fn header ->
                 header == {"x-api-key", created_api_key}
               end)

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      response = HttpClient.get(url, config_overrides)

      assert {:ok, %Response{}} = response
    end

    test "renew api key when expired", %{bypass: bypass} do
      url = "/transactions"
      expired_api_key = create_and_save_api_key()
      created_api_key = "http-client-valid-api-key-003"

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn %{req_headers: headers} = conn ->
        case Enum.find(headers, &(elem(&1, 0) == "x-api-key")) do
          {_key, ^expired_api_key} ->
            Conn.resp(conn, 403, ~s<{"message":"Missing or invalid authorization token"}>)

          {_key, ^created_api_key} ->
            Conn.resp(conn, 200, ~s<{"message": "ok"}>)
        end
      end)

      bypass_expect(bypass, "POST", "auth", fn conn ->
        Conn.resp(conn, 200, ~s<{"apiKey": "#{created_api_key}"}>)
      end)

      response = HttpClient.get(url, config_overrides)

      assert {:ok, %Response{}} = response

      assert Enum.any?(:sys.get_state(Guard), fn {_key, %{api_key: value}} ->
               value == created_api_key
             end)
    end

    test "fail to renew api key when expired", %{bypass: bypass} do
      url = "/transactions"
      create_and_save_api_key()

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn conn ->
        Conn.resp(conn, 403, ~s<{"message":"Missing or invalid authorization token"}>)
      end)

      bypass_expect(bypass, "POST", "auth", fn conn ->
        Conn.resp(conn, 401, ~s<{"message":"Client keys are invalid","code":401}>)
      end)

      response = HttpClient.get(url, config_overrides)

      assert {:error, %Error{}} = response
    end
  end

  describe "get/2" do
    test "perform a get request", %{bypass: bypass} do
      create_and_save_api_key()

      url = "/transactions"
      query = [custom: "custom-value"]

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn conn ->
        assert conn.query_params == %{"custom" => "custom-value", "sandbox" => "true"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      response = HttpClient.get(url, query, config_overrides)

      assert {:ok, %Response{status: 200, body: %{"message" => "ok"}}} = response
    end
  end

  describe "post/2" do
    test "perform a post request", %{bypass: bypass} do
      create_and_save_api_key()

      url = "/transactions"
      body = %{key: "value"}
      query = [custom: "custom-value"]

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "POST", url, fn conn ->
        assert conn.query_params == %{"custom" => "custom-value", "sandbox" => "true"}
        assert conn.body_params == %{"key" => "value"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      response = HttpClient.post(url, body, query, config_overrides)

      assert {:ok, %Response{status: 200, body: %{"message" => "ok"}}} = response
    end
  end

  describe "patch/2" do
    test "perform a patch request", %{bypass: bypass} do
      create_and_save_api_key()

      url = "/transactions"
      body = %{key: "value"}
      query = [custom: "custom-value"]

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "PATCH", url, fn conn ->
        assert conn.query_params == %{"custom" => "custom-value", "sandbox" => "true"}
        assert conn.body_params == %{"key" => "value"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      response = HttpClient.patch(url, body, query, config_overrides)

      assert {:ok, %Response{status: 200, body: %{"message" => "ok"}}} = response
    end
  end

  describe "[ error handle ]" do
    test "parse a forbidden error", %{bypass: bypass} do
      create_and_save_api_key()

      url = "/transactions"

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn conn ->
        Conn.resp(conn, 403, ~s<{"message":"Forbidden"}>)
      end)

      response = HttpClient.get(url, config_overrides)

      assert response == {:error, %Error{message: "Forbidden", code: 403}}
    end

    test "handle non JSON response errors", %{bypass: bypass} do
      create_and_save_api_key()

      url = "/transactions"

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn conn ->
        Conn.resp(
          conn,
          500,
          ~s[<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Error</title></head><body><pre>Internal Server Error</pre></body></html>]
        )
      end)

      response = HttpClient.get(url, config_overrides)

      assert response == {
               :error,
               %Error{
                 code: 500,
                 message: "response body is not a valid JSON",
                 details:
                   ~s[<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Error</title></head><body><pre>Internal Server Error</pre></body></html>]
               }
             }
    end
  end
end
