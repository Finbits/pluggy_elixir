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

  ## Configuration Override
  You can always override the configuration by passing a keyword to client functions

  ### Example
      iex> PluggyElixir.Auth.create_api_key(client_id: "someid", client_secret: "somesecret")

  Overridable configs
  - client_id
  - client_secret
  - scope
  - non_expiring_api_key
  - sandbox
  - host

  """

  defmodule Auth do
    @moduledoc false
    defstruct([:scope, :client_id, :client_secret, :api_key, :non_expiring_api_key])

    @type t() :: %__MODULE__{
            scope: binary(),
            client_id: binary(),
            client_secret: binary(),
            api_key: binary(),
            non_expiring_api_key: boolean()
          }
  end

  defmodule Adapter do
    @moduledoc false
    defstruct([:module, :configs])

    @type t() :: %__MODULE__{
            module: atom(),
            configs: Keyword.t()
          }
  end

  alias PluggyElixir.Config.{Adapter, Auth}

  defstruct [:host, :sandbox, :auth, :adapter]

  @type t :: %__MODULE__{
          host: URI.t(),
          sandbox: boolean(),
          auth: Auth.t(),
          adapter: Adapter.t()
        }

  @typedoc """
  You can create separeted scope for your authentication by specifying a scope key
  """
  @type scope :: {:scope, binary()}

  @type config_overrides :: [
          {:client_id, binary()}
          | {:client_secret, binary()}
          | {:non_expiring_api_key, boolean()}
          | {:sandbox, boolean()}
          | {:host, binary()}
          | scope()
        ]

  @default_host "api.pluggy.ai"

  @doc false
  @spec override(config_overrides()) :: t()
  def override(overrides) do
    :pluggy_elixir
    |> Application.get_all_env()
    |> Keyword.merge(overrides)
    |> build_config()
  end

  defp build_config(configs) do
    %__MODULE__{
      host: host_uri(configs),
      sandbox: ensure_boolean(get(configs, :sandbox)),
      adapter: %Adapter{
        module: PluggyElixir.HttpAdapter.Tesla,
        configs: [adapter: Tesla.Adapter.Hackney]
      },
      auth: %Auth{
        scope: get(configs, :scope, "pluggy_elixir"),
        client_id: get(configs, :client_id, :pluggy_elixir),
        client_secret: get(configs, :client_secret, :pluggy_elixir),
        api_key: get(configs, :api_key),
        non_expiring_api_key: ensure_boolean(get(configs, :non_expiring_api_key))
      }
    }
  end

  defp host_uri(configs) do
    ~r"(?<scheme>http[s]?)?(:[\/]{2})?(?<host>[\w\.]+)(:?(?<port>\d+))?(\/(?<path>.*))?"
    |> Regex.named_captures(get(configs, :host, @default_host))
    |> to_uri()
  end

  defp to_uri(captures) do
    %URI{
      scheme: get_captured(captures, "scheme", "https"),
      host: get_captured(captures, "host"),
      port: port_to_integer(get_captured(captures, "port")),
      path: get_captured(captures, "path")
    }
  end

  defp port_to_integer(port) when is_binary(port), do: String.to_integer(port)
  defp port_to_integer(port), do: port

  defp get_captured(captures, key, default \\ nil) do
    case Map.get(captures, key, default) do
      "" -> default
      value -> value
    end
  end

  defp ensure_boolean(true), do: true
  defp ensure_boolean(_any), do: false

  defp get(keyword, key, default \\ nil),
    do: Keyword.get(keyword, key, default)
end
