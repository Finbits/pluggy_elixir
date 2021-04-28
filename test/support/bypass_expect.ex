defmodule PluggyElixir.BypassExpect do
  alias Plug.Conn

  def bypass_expect(bypass, method, url, mock_func) do
    Bypass.expect(bypass, method, url, fn conn ->
      conn
      |> validate_content_type()
      |> Conn.read_body()
      |> json_decode()
      |> Conn.put_resp_header("content-type", "application/json")
      |> mock_func.()
    end)
  end

  defp validate_content_type(conn) do
    conn
    |> Conn.get_req_header("content-type")
    |> case do
      ["application/json" <> _tail] -> conn
      _other -> custom_raise("Pluggy API requires content-type: application/json header")
    end
  end

  defp json_decode({:ok, body, conn}) do
    body
    |> case do
      "" -> {:ok, %{}}
      json -> Jason.decode(json)
    end
    |> add_body(conn)
  end

  defp add_body({:ok, body}, conn) when is_map(body) do
    %{conn | body_params: body, params: Map.merge(conn.params, body)}
  end

  defp add_body({:error, reason}, _conn) do
    custom_raise(
      "Pluggy API just accept body with JSON format. The Jason.decode/1 failed with #{
        inspect(reason)
      }"
    )
  end

  defp custom_raise(msg), do: raise("\n\n\n>>>>>> Bypass error:\n\n#{msg}\n\n<<<<<<\n\n\n")
end
