defmodule PluggyElixir.HttpAdapter.Tesla do
  @moduledoc """
  Implements `PluggyElixir.HttpAdapter` behaviour using `Tesla`.
  """
  alias PluggyElixir.Config
  alias PluggyElixir.HttpAdapter.Response

  @behaviour PluggyElixir.HttpAdapter

  @impl true
  def post(url, body, query \\ [], headers \\ []) do
    build_client()
    |> Tesla.post(url, body, build_options(query, headers))
    |> format_response()
  end

  @impl true
  def get(url, query \\ [], headers \\ []) do
    build_client()
    |> Tesla.get(url, build_options(query, headers))
    |> format_response()
  end

  defp build_options(query, headers) do
    [
      query: build_query(query),
      headers: headers
    ]
  end

  defp build_query(query),
    do: if(Config.sandbox(), do: Keyword.merge(query, sandbox: true), else: query)

  defp build_client do
    Tesla.client(
      [
        {Tesla.Middleware.BaseUrl, host_uri()},
        {Tesla.Middleware.Headers, [{"content-type", "application/json"}]},
        Tesla.Middleware.JSON
      ],
      Keyword.fetch!(Config.get_http_adapter_config(), :adapter)
    )
  end

  defp format_response({:ok, %Tesla.Env{body: body, headers: headers, status: status}}),
    do: {:ok, %Response{body: body, headers: headers, status: status}}

  defp format_response({:error, reason}) when is_atom(reason),
    do: {:error, Atom.to_string(reason)}

  defp format_response({:error, {Tesla.Middleware.JSON, :decode, _error}}),
    do: {:error, "response body is not a valid JSON"}

  defp format_response({:error, reason}), do: {:error, inspect(reason)}

  defp host_uri, do: to_string(Config.get_host_uri())
end
