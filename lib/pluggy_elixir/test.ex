defmodule PluggyElixir.Test do
  @moduledoc """
  Support module to crate test form `PluggyElixir`
  """
  alias PluggyElixir.Auth.Guard

  def create_and_save_api_key do
    auth = %PluggyElixir.Auth{api_key: "generated_api_key_#{:rand.uniform()}"}

    Guard.set_auth(auth)

    auth.api_key
  end

  if Code.ensure_loaded?(Bypass) do
    alias Plug.Conn

    def bypass_expect(bypass, method, url, mock_func) do
      caller = self()

      Bypass.expect(bypass, method, url, fn conn ->
        conn
        |> validate_content_type()
        |> Conn.read_body()
        |> json_decode()
        |> Conn.put_resp_header("content-type", "application/json")
        |> notify_caller(caller)
        |> mock_func.()
      end)
    end

    defmacro assert_pluggy(value, timeout \\ 3000) do
      assertion =
        if(is_fn(value),
          do: quote(do: unquote(value).(conn)),
          else: quote(do: assert(unquote(value) = conn))
        )

      quote do
        receive do
          {:bypass, conn} ->
            unquote(assertion)
        after
          unquote(timeout) -> raise("Bypass message not received")
        end
      end
    end

    defp is_fn({:fn, _line, _code}), do: true
    defp is_fn(_any), do: false

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

    defp notify_caller(%Conn{} = conn, caller) do
      Process.send(
        caller,
        {:bypass,
         Map.take(conn, [:params, :body_params, :query_params, :path_params, :req_headers])},
        []
      )

      conn
    end

    defp custom_raise(msg), do: raise("\n\n\n>>>>>> Bypass error:\n\n#{msg}\n\n<<<<<<\n\n\n")
  end
end
