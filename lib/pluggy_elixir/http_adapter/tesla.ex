defmodule PluggyElixir.HttpAdapter.Tesla do
  @moduledoc """
  Implements `PluggyElixir.HttpAdapter` behaviour using `Tesla`.
  """
  alias PluggyElixir.Config
  alias PluggyElixir.HttpAdapter.Response

  @behaviour PluggyElixir.HttpAdapter

  @impl true
  def post(url, body, query \\ [], headers \\ [], %Config{} = config) do
    config
    |> build_client()
    |> Tesla.post(url, body, build_options(query, headers, config))
    |> format_response()
  end

  @impl true
  def get(url, query \\ [], headers \\ [], %Config{} = config) do
    config
    |> build_client()
    |> Tesla.get(url, build_options(query, headers, config))
    |> format_response()
  end

  defp build_options(query, headers, %{sandbox: sandbox}) do
    [
      query: build_query(query, sandbox),
      headers: headers
    ]
  end

  defp build_query(query, true), do: Keyword.merge(query, sandbox: true)
  defp build_query(query, _false), do: query

  defp build_client(config) do
    Tesla.client(
      [
        {Tesla.Middleware.BaseUrl, host_uri(config)},
        {Tesla.Middleware.Headers, [{"content-type", "application/json"}]},
        Tesla.Middleware.JSON
      ],
      get_tesla_adapter(config)
    )
  end

  defp format_response({:ok, %Tesla.Env{body: body, headers: headers, status: status}}),
    do: {:ok, %Response{body: body, headers: headers, status: status}}

  defp format_response({:error, reason}) when is_atom(reason),
    do: {:error, Atom.to_string(reason)}

  defp format_response({:error, {Tesla.Middleware.JSON, :decode, _error}}),
    do: {:error, "response body is not a valid JSON"}

  defp format_response({:error, reason}), do: {:error, inspect(reason)}

  defp get_tesla_adapter(%{adapter: %{configs: adapter_config}}),
    do: Keyword.fetch!(adapter_config, :adapter)

  defp host_uri(%{host: host}), do: to_string(host)
end
