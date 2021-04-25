defmodule PluggyElixir.HttpClient do
  @moduledoc false

  alias PluggyElixir.Auth.Guard
  alias PluggyElixir.{Auth, Config, HttpAdapter}
  alias PluggyElixir.HttpAdapter.Response

  @expired_msg "Missing or invalid authorization token"

  @spec get(HttpAdapter.url(), HttpAdapter.query()) :: {:ok, Response.t()} | {:error, binary()}

  def get(url, query \\ []), do: http_request(%{method: :get, url: url, query: query})

  @spec post(HttpAdapter.url(), HttpAdapter.body(), HttpAdapter.query()) ::
          {:ok, Response.t()} | {:error, binary()}

  def post(url, body, query \\ []),
    do: http_request(%{method: :post, url: url, body: body, query: query})

  defp http_request(request) do
    with %Auth{} = auth <- retrieve_auth(),
         authenticated <- authenticate(auth, request),
         {:performed, response} <- perform_request(authenticated) do
      return_or_retry(response, request)
    end
  end

  defp return_or_retry({:ok, %Response{status: 403, body: %{"message" => @expired_msg}}}, request) do
    with %Auth{} = auth <- renew_auth(),
         authenticated <- authenticate(auth, request),
         {:performed, response} <- perform_request(authenticated) do
      response
    end
  end

  defp return_or_retry(return, _request), do: return

  defp authenticate(%Auth{api_key: api_key}, request),
    do: Map.put(request, :headers, [{"X-API-KEY", api_key}])

  defp perform_request(%{method: :get, url: url, query: query, headers: headers}),
    do: {:performed, http_adapter().get(url, query, headers)}

  defp perform_request(%{method: :post, url: url, body: body, query: query, headers: headers}),
    do: {:performed, http_adapter().post(url, body, query, headers)}

  defp retrieve_auth do
    case Guard.get_auth() do
      %Auth{} = auth -> auth
      _any -> renew_auth()
    end
  end

  defp renew_auth do
    case Auth.create_api_key() do
      {:ok, auth} ->
        Guard.set_auth(auth)
        auth

      {:error, reason} = error ->
        Guard.set_auth(reason)
        error
    end
  end

  defp http_adapter, do: Config.get_http_adapter()
end
