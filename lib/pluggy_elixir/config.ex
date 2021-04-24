defmodule PluggyElixir.Config do
  @moduledoc """
  PluggyElixir client configurations

  To use `PluggyElixir` you must add into your config file `config.exs` the
  required config:

      config :pluggy_elixir,
        client_id: "your-app-client-id",
        client_secret: "your-app-client-secret",


  Allowed configuration:

  - client_id(required): A client id provide by Pluggy
  - client_secret(required): A client secret provide by Pluggy
  - non_expiring_api_key: A boolean value to enable create a non expiring API
  KEY. (default is `false`)
  - sandbox: A boolean value to enable using sandbox `Connector`. (default is `false`)
  - host: A string containing the API host. (default is `"api.pluggy.ai"`)

  """

  @default_host "api.pluggy.ai"

  @doc false
  def get_client_id, do: get_pluggy_elixir_config(:client_id)

  @doc false
  def get_client_secret, do: get_pluggy_elixir_config(:client_secret)

  @doc false
  def get_host_uri do
    ~r"(?<scheme>http[s]?)?(:[\/]{2})?(?<host>[\w\.]+)(:?(?<port>\d+))?(\/(?<path>.*))?"
    |> Regex.named_captures(get_pluggy_elixir_config(:host, @default_host))
    |> to_uri()
  end

  @doc false
  def non_expiring_api_key,
    do: if(get_pluggy_elixir_config(:non_expiring_api_key, false) == true, do: true, else: false)

  @doc false
  def sandbox,
    do: if(get_pluggy_elixir_config(:sandbox, false) == true, do: true, else: false)

  @doc false
  def get_http_adapter_config, do: [adapter: Tesla.Adapter.Hackney]

  defp to_uri(captures) do
    %URI{
      scheme: get_captured(captures, "scheme", "https"),
      host: get_captured(captures, "host"),
      port: port_to_integer(get_captured(captures, "port")),
      path: get_captured(captures, "path")
    }
  end

  defp get_captured(captures, key, default \\ nil) do
    case Map.get(captures, key, default) do
      "" -> default
      value -> value
    end
  end

  defp port_to_integer(port) when is_binary(port), do: String.to_integer(port)
  defp port_to_integer(port), do: port

  defp get_pluggy_elixir_config(key, default_value \\ :required, custom_message \\ nil) do
    case Application.get_env(:pluggy_elixir, key, default_value) do
      :required -> config_error(key, custom_message)
      value -> config_success(value, default_value)
    end
  end

  defp config_error(key, nil), do: {:error, "Missing PluggyElixir configuration: [ #{key} ]"}

  defp config_success(value, :required), do: {:ok, value}
  defp config_success(value, _no_required), do: value
end
