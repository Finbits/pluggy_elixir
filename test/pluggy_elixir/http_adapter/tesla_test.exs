defmodule PluggyElixir.HttpAdapter.TeslaTest do
  use PluggyElixir.Case, async: false

  alias PluggyElixir.HttpAdapter.{Response, Tesla}

  setup do
    config = Application.get_all_env(:pluggy_elixir)

    on_exit(fn ->
      Application.put_all_env(pluggy_elixir: config)
    end)

    :ok
  end

  describe "post/3" do
    test "perform a post request and return status, body and headers", %{bypass: bypass} do
      url = "/auth"
      body = %{"key" => "value"}

      bypass_expect(bypass, "POST", url, fn conn ->
        assert conn.body_params == body

        conn
        |> Conn.put_resp_header("custom-header", "custom-value")
        |> Conn.resp(200, ~s<{"message": "ok"}>)
      end)

      response = Tesla.post(url, body)

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

      bypass_expect(bypass, "POST", url, fn conn ->
        assert conn.query_params == %{"sandbox" => "true", "custom" => "custom-value"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.post(url, %{}, query)
    end

    test "send query sandbox as true when sandbox is configured", %{bypass: bypass} do
      Application.put_env(:pluggy_elixir, :sandbox, true)

      url = "/auth"

      bypass_expect(bypass, "POST", url, fn conn ->
        assert conn.query_params == %{"sandbox" => "true"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.post(url, %{})
    end

    test "dont send query sandbox when sandbox is configured to false", %{bypass: bypass} do
      Application.put_env(:pluggy_elixir, :sandbox, false)

      url = "/auth"

      bypass_expect(bypass, "POST", url, fn conn ->
        assert conn.query_params == %{}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.post(url, %{})
    end

    test "return success even when response status is a client error", %{bypass: bypass} do
      url = "/auth"

      bypass_expect(bypass, "POST", url, fn conn ->
        Conn.resp(conn, 422, ~s<{"error": "fail"}>)
      end)

      assert {:ok, %Response{status: 422, body: %{"error" => "fail"}}} = Tesla.post(url, %{})
    end

    test "return success even when response status is a server error", %{bypass: bypass} do
      url = "/auth"

      bypass_expect(bypass, "POST", url, fn conn ->
        Conn.resp(conn, 500, ~s<{"error": "fail"}>)
      end)

      assert {:ok, %Response{status: 500, body: %{"error" => "fail"}}} = Tesla.post(url, %{})
    end

    test "return error when response isnt a valid json", %{bypass: bypass} do
      url = "/auth"

      bypass_expect(bypass, "POST", url, fn conn ->
        Conn.resp(conn, 200, ~s<not a valid json>)
      end)

      assert Tesla.post(url, %{}) == {:error, "response body is not a valid JSON"}
    end

    test "return error when server is down", %{bypass: bypass} do
      url = "/auth"

      Bypass.down(bypass)

      assert Tesla.post(url, %{}) == {:error, "econnrefused"}
    end

    test "return error when cant resolve hostname" do
      Application.put_env(:pluggy_elixir, :host, "invalid.host.ex")

      url = "/auth"

      assert Tesla.post(url, %{}) == {:error, "nxdomain"}
    end
  end

  describe "get/2" do
    test "perform a get request and return status, body and headers", %{bypass: bypass} do
      url = "/auth"

      bypass_expect(bypass, "GET", url, fn conn ->
        conn
        |> Conn.put_resp_header("custom-header", "custom-value")
        |> Conn.resp(200, ~s<{"message": "ok"}>)
      end)

      response = Tesla.get(url)

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

      bypass_expect(bypass, "GET", url, fn conn ->
        assert conn.query_params == %{"sandbox" => "true", "custom" => "custom-value"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.get(url, query)
    end

    test "send query sandbox as true when sandbox is configured", %{bypass: bypass} do
      Application.put_env(:pluggy_elixir, :sandbox, true)

      url = "/auth"

      bypass_expect(bypass, "GET", url, fn conn ->
        assert conn.query_params == %{"sandbox" => "true"}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.get(url)
    end

    test "dont send query sandbox when sandbox is configured to false", %{bypass: bypass} do
      Application.put_env(:pluggy_elixir, :sandbox, false)

      url = "/auth"

      bypass_expect(bypass, "GET", url, fn conn ->
        assert conn.query_params == %{}

        Conn.resp(conn, 200, ~s<{"message": "ok"}>)
      end)

      assert {:ok, %Response{}} = Tesla.get(url)
    end

    test "return success even when response status is a client error", %{bypass: bypass} do
      url = "/auth"

      bypass_expect(bypass, "GET", url, fn conn ->
        Conn.resp(conn, 422, ~s<{"error": "fail"}>)
      end)

      assert {:ok, %Response{status: 422, body: %{"error" => "fail"}}} = Tesla.get(url)
    end

    test "return success even when response status is a server error", %{bypass: bypass} do
      url = "/auth"

      bypass_expect(bypass, "GET", url, fn conn ->
        Conn.resp(conn, 500, ~s<{"error": "fail"}>)
      end)

      assert {:ok, %Response{status: 500, body: %{"error" => "fail"}}} = Tesla.get(url)
    end

    test "return error when response isnt a valid json", %{bypass: bypass} do
      url = "/auth"

      bypass_expect(bypass, "GET", url, fn conn ->
        Conn.resp(conn, 200, ~s<not a valid json>)
      end)

      assert Tesla.get(url) == {:error, "response body is not a valid JSON"}
    end

    test "return error when server is down", %{bypass: bypass} do
      url = "/auth"

      Bypass.down(bypass)

      assert Tesla.get(url) == {:error, "econnrefused"}
    end

    test "return error when cant resolve hostname" do
      Application.put_env(:pluggy_elixir, :host, "invalid.host.ex")

      url = "/auth"

      assert Tesla.get(url) == {:error, "nxdomain"}
    end
  end
end
