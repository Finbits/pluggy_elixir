defmodule PluggyElixir.HttpAdapter.TeslaTest do
  use PluggyElixir.Case, async: true

  alias PluggyElixir.Config
  alias PluggyElixir.HttpAdapter.{Response, Tesla}

  describe "post/4" do
    test "perform a post request and return status, body and headers", %{bypass: bypass} do
      url = "/auth"
      body = %{"key" => "value"}

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "POST", url, fn conn ->
        assert conn.body_params == body

        conn
        |> Conn.put_resp_header("custom-header", "custom-value")
        |> Conn.resp(200, ~s<{"message": "ok"}>)
      end)

      response = Tesla.post(url, body, [], config_overrides)

      assert {:ok,
              %Response{
                status: 200,
                body: %{"message" => "ok"},
                headers: headers
              }} = response

      assert Enum.find(headers, fn {key, _v} -> key == "custom-header" end) ==
               {"custom-header", "custom-value"}
    end

    test "sending a custom query", %{bypass: bypass} do
      url = "/auth"
      query = [custom: "custom-value"]

      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "POST", url, fn conn ->
        assert conn.query_params == %{"sandbox" => "true", "custom" => "custom-value"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.post(url, %{}, query, config_overrides)
    end

    test "sending custom headers", %{bypass: bypass} do
      url = "/auth"
      headers = [{"custom-header", "custom-value"}]
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "POST", url, fn conn ->
        assert Enum.any?(headers, fn header -> [header] == headers end) == true

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.post(url, %{}, [], headers, config_overrides)
    end

    test "send query sandbox as true when sandbox is configured", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}", sandbox: true)

      bypass_expect(bypass, "POST", url, fn conn ->
        assert conn.query_params == %{"sandbox" => "true"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.post(url, %{}, [], config_overrides)
    end

    test "don't send query sandbox when sandbox is configured to false", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}", sandbox: false)

      bypass_expect(bypass, "POST", url, fn conn ->
        assert conn.query_params == %{}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.post(url, %{}, [], config_overrides)
    end

    test "return success even when response status is a client error", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "POST", url, fn conn ->
        Conn.resp(conn, 422, ~s<{"error": "fail"}>)
      end)

      assert {:ok, %Response{status: 422, body: %{"error" => "fail"}}} =
               Tesla.post(url, %{}, [], config_overrides)
    end

    test "return success even when response status is a server error", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "POST", url, fn conn ->
        Conn.resp(conn, 500, ~s<{"error": "fail"}>)
      end)

      assert {:ok, %Response{status: 500, body: %{"error" => "fail"}}} =
               Tesla.post(url, %{}, [], config_overrides)
    end

    test "return error when response isn't a valid json", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "POST", url, fn conn ->
        Conn.resp(conn, 200, ~s<not a valid json>)
      end)

      assert Tesla.post(url, %{}, [], config_overrides) ==
               {:error, "response body is not a valid JSON"}
    end

    test "return error when server is down", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      Bypass.down(bypass)

      assert Tesla.post(url, %{}, [], config_overrides) == {:error, "econnrefused"}
    end

    test "return error when can't resolve hostname" do
      url = "/auth"
      config_overrides = Config.override(host: "invalid.host.ex")

      assert Tesla.post(url, %{}, config_overrides) == {:error, "nxdomain"}
    end
  end

  describe "get/3" do
    test "perform a get request and return status, body and headers", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn conn ->
        conn
        |> Conn.put_resp_header("custom-header", "custom-value")
        |> Conn.resp(200, ~s<{"message": "ok"}>)
      end)

      response = Tesla.get(url, config_overrides)

      assert {:ok,
              %Response{
                status: 200,
                body: %{"message" => "ok"},
                headers: headers
              }} = response

      assert Enum.find(headers, fn {key, _v} -> key == "custom-header" end) ==
               {"custom-header", "custom-value"}
    end

    test "sending a custom query", %{bypass: bypass} do
      url = "/auth"
      query = [custom: "custom-value"]
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn conn ->
        assert conn.query_params == %{"sandbox" => "true", "custom" => "custom-value"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.get(url, query, config_overrides)
    end

    test "sending custom headers", %{bypass: bypass} do
      url = "/auth"
      headers = [{"custom-headers", "custom-value"}]
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn conn ->
        assert Enum.any?(headers, fn header -> [header] == headers end) == true

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.get(url, [], headers, config_overrides)
    end

    test "send query sandbox as true when sandbox is configured", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}", sandbox: true)

      bypass_expect(bypass, "GET", url, fn conn ->
        assert conn.query_params == %{"sandbox" => "true"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.get(url, config_overrides)
    end

    test "don't send query sandbox when sandbox is configured to false", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}", sandbox: false)

      bypass_expect(bypass, "GET", url, fn conn ->
        assert conn.query_params == %{}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.get(url, config_overrides)
    end

    test "return success even when response status is a client error", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn conn ->
        Conn.resp(conn, 422, ~s<{"error": "fail"}>)
      end)

      assert {:ok, %Response{status: 422, body: %{"error" => "fail"}}} =
               Tesla.get(url, config_overrides)
    end

    test "return success even when response status is a server error", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn conn ->
        Conn.resp(conn, 500, ~s<{"error": "fail"}>)
      end)

      assert {:ok, %Response{status: 500, body: %{"error" => "fail"}}} =
               Tesla.get(url, config_overrides)
    end

    test "return error when response isn't a valid json", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      bypass_expect(bypass, "GET", url, fn conn ->
        Conn.resp(conn, 200, ~s<not a valid json>)
      end)

      assert Tesla.get(url, config_overrides) == {:error, "response body is not a valid JSON"}
    end

    test "return error when server is down", %{bypass: bypass} do
      url = "/auth"
      config_overrides = Config.override(host: "http://localhost:#{bypass.port}")

      Bypass.down(bypass)

      assert Tesla.get(url, config_overrides) == {:error, "econnrefused"}
    end

    test "return error when can't resolve hostname" do
      url = "/auth"
      config_overrides = Config.override(host: "invalid.host.ex")

      assert Tesla.get(url, config_overrides) == {:error, "nxdomain"}
    end
  end
end
