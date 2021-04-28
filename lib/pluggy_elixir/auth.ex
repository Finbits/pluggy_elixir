defmodule PluggyElixir.Auth do
  @moduledoc """
  Handle authentication actions.
  """

  alias PluggyElixir.Config
  alias PluggyElixir.HttpClient.Error

  @auth_path "/auth"

  defstruct [:api_key]

  @type t :: %__MODULE__{
          api_key: binary()
        }

  @doc """
  Create an API Key using configured client_id and client_secret.

  The API Key is used to authenticate all requests to Pluggy API.
  """

  @spec create_api_key(Config.config_overrides() | Config.t()) :: {:ok, t()} | {:error, binary()}
  def create_api_key(config_overrides \\ [])

  def create_api_key(config_overrides) when is_list(config_overrides) do
    config_overrides
    |> Config.override()
    |> create_api_key()
  end

  def create_api_key(%Config{} = config) do
    config
    |> build_api_key_params()
    |> perform_request()
    |> create_api_key_response()
  end

  defp build_api_key_params(%{auth: auth} = config) do
    {config,
     %{
       clientId: auth.client_id,
       clientSecret: auth.client_secret,
       nonExpiring: auth.non_expiring_api_key
     }}
  end

  defp perform_request({%{adapter: %{module: http_adapter}} = config, request_body}),
    do: http_adapter.post(@auth_path, request_body, config)

  defp create_api_key_response({:ok, %{status: 200, body: %{"apiKey" => api_key}}}),
    do: {:ok, %__MODULE__{api_key: api_key}}

  defp create_api_key_response({:ok, response}), do: {:error, Error.parse(response)}
  defp create_api_key_response(error), do: error
end
