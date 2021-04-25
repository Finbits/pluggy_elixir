defmodule PluggyElixir.Auth do
  @moduledoc """
  Handle authentication actions.
  """

  alias PluggyElixir.Config
  alias PluggyElixir.Error

  @type t :: %__MODULE__{
          api_key: binary()
        }

  defstruct [:api_key]

  @auth_path "/auth"

  @spec create_api_key :: {:ok, t()} | {:error, binary()}

  @doc """
  Create an API Key using configured client_id and client_secret.

  The API Key is used to authenticate all requests to Pluggy API.
  """
  def create_api_key do
    build_api_key_params()
    |> perform_request()
    |> create_api_key_response()
  end

  defp build_api_key_params do
    with {:ok, client_id} <- Config.get_client_id(),
         {:ok, client_secret} <- Config.get_client_secret() do
      %{
        clientId: client_id,
        clientSecret: client_secret,
        nonExpiring: Config.non_expiring_api_key()
      }
    end
  end

  defp perform_request(params) when is_map(params), do: http_client().post(@auth_path, params)
  defp perform_request(error), do: error

  defp create_api_key_response({:ok, %{status: 200, body: %{"apiKey" => api_key}}}),
    do: {:ok, %__MODULE__{api_key: api_key}}

  defp create_api_key_response({:ok, response}), do: {:error, Error.parse(response)}
  defp create_api_key_response(error), do: error

  defp http_client, do: Config.get_http_adapter()
end
