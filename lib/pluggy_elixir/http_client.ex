defmodule PluggyElixir.HttpClient do
  @moduledoc false

  alias PluggyElixir.Auth.Guard
  alias PluggyElixir.{Auth, Config, HttpAdapter}
  alias PluggyElixir.HttpAdapter.Response
  alias PluggyElixir.HttpClient.Error

  @expired_msg "Missing or invalid authorization token"

  @spec get(HttpAdapter.url(), HttpAdapter.query(), Config.t()) ::
          {:ok, Response.t()} | {:error, binary()}

  def get(url, query \\ [], %Config{} = config),
    do: http_request(%{method: :get, url: url, query: query}, config)

  @spec post(HttpAdapter.url(), HttpAdapter.body(), HttpAdapter.query(), Config.t()) ::
          {:ok, Response.t()} | {:error, binary()}

  def post(url, body, query \\ [], %Config{} = config),
    do: http_request(%{method: :post, url: url, body: body, query: query}, config)

  @spec patch(HttpAdapter.url(), HttpAdapter.body(), HttpAdapter.query(), Config.t()) ::
          {:ok, Response.t()} | {:error, binary()}

  def patch(url, body, query \\ [], %Config{} = config),
    do: http_request(%{method: :patch, url: url, body: body, query: query}, config)

  defp http_request(request, config) do
    with %Auth{} = auth <- retrieve_auth(config),
         authenticated <- authenticate(auth, request),
         {:performed, response} <- perform_request(authenticated, config),
         result <- return_or_retry(response, request, config) do
      handle_result(result)
    end
  end

  defp return_or_retry(
         {:ok, %Response{status: 403, body: %{"message" => @expired_msg}}},
         request,
         config
       ) do
    with %Auth{} = auth <- renew_auth(config),
         authenticated <- authenticate(auth, request),
         {:performed, response} <- perform_request(authenticated, config) do
      response
    end
  end

  defp return_or_retry(return, _request, _config), do: return

  defp authenticate(%Auth{api_key: api_key}, request),
    do: Map.put(request, :headers, [{"X-API-KEY", api_key}])

  defp perform_request(
         %{method: :get, url: url, query: query, headers: headers},
         %{adapter: %{module: http_adapter}} = config
       ),
       do: {:performed, http_adapter.get(url, query, headers, config)}

  defp perform_request(
         %{method: method, url: url, body: body, query: query, headers: headers},
         %{adapter: %{module: http_adapter}} = config
       )
       when method in [:post, :patch, :put],
       do: {:performed, apply(http_adapter, method, [url, body, query, headers, config])}

  defp retrieve_auth(config) do
    case Guard.get_auth() do
      %Auth{} = auth -> auth
      _any -> renew_auth(config)
    end
  end

  defp renew_auth(config) do
    case Auth.create_api_key(config) do
      {:ok, auth} ->
        Guard.set_auth(auth)
        auth

      {:error, reason} = error ->
        Guard.set_auth_error(reason)
        error
    end
  end

  defp handle_result({:ok, %Response{status: status}} = success)
       when status >= 200 and status < 300,
       do: success

  defp handle_result({:ok, %Response{} = response}),
    do: {:error, Error.parse(response)}

  defp handle_result({:error, %{message: message, details: details}}),
    do: {:error, %Error{code: 500, message: message, details: details}}

  defp handle_result({:error, _reason} = error), do: error
end
