defmodule PluggyElixir.Webhook do
  @moduledoc """
  Handle webhooks actions.
  """

  alias PluggyElixir.{Config, HttpClient}

  defstruct [:created_at, :event, :id, :updated_at, :url]

  @type t() :: %__MODULE__{
          id: binary(),
          event: binary(),
          url: binary(),
          created_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @webhooks_path "/webhooks"

  @doc """
  List all created webhooks.

  ### Examples

      iex> Webhook.all()
      {:ok,
       [
         %Webhook{
           created_at: ~N[2021-04-26 17:41:12.093],
           event: "item/updated",
           id: "3f1f222b-6efa-4736-8ded-8b14646f79bc",
           updated_at: ~N[2021-04-26 17:41:12.093],
           url: "https://finbits.com.br/webhook"
         }
       ]}
  """

  @spec all(Config.config_overrides()) :: {:ok, [t()]} | {:error, PluggyElixir.Error.t()}

  def all(config_overrides \\ []) do
    @webhooks_path
    |> HttpClient.get(Config.override(config_overrides))
    |> handle_response(:all)
  end

  @doc """
  Register a new global webhook

  ### Examples

      iex> Webhook.create(%{event: "all", url: "https://finbits.com.br/webhook"})
      {:ok,
       %Webhook{
         created_at: ~N[2021-04-26 17:41:12.093],
         event: "all",
         id: "3f1f889b-6efa-4736-8ded-8b14646f79ca",
         updated_at: ~N[2021-04-26 17:41:12.093],
         url: "https://finbits.com.br/webhook"
       }}
  """

  @spec create(%{event: binary(), url: binary()}, Config.config_overrides()) ::
          {:ok, [t()]} | {:error, PluggyElixir.HttpClient.Error.t() | binary()}

  def create(params, config_overrides \\ [])

  def create(%{event: _event, url: _url} = params, config_overrides) do
    @webhooks_path
    |> HttpClient.post(params, Config.override(config_overrides))
    |> handle_response(:create)
  end

  def create(_params, _config_overrides), do: {:error, ":event and :url are required"}

  @doc """
  Update an existent global webhook

  You can update just the webhook `event` or both (`event` and `url`)

  ### Examples

      iex> Webhook.update(%{id: "3f1f889b-6efa-4736-8ded-8b14646f79ca", event: "all", url: "https://finbits.com.br/webhook"})
      {:ok,
       %Webhook{
         created_at: ~N[2021-04-26 17:41:12.093],
         event: "all",
         id: "3f1f889b-6efa-4736-8ded-8b14646f79ca",
         updated_at: ~N[2021-04-26 17:41:12.093],
         url: "https://finbits.com.br/webhook"
       }}
  """

  @spec update(
          %{:id => binary(), :event => binary(), optional(:url) => binary()},
          Config.config_overrides()
        ) ::
          {:ok, [t()]} | {:error, PluggyElixir.HttpClient.Error.t() | binary()}

  def update(params, config_overrides \\ [])

  def update(%{id: id, event: _event} = params, config_overrides) do
    "#{@webhooks_path}/#{id}"
    |> HttpClient.patch(params, Config.override(config_overrides))
    |> handle_response(:update)
  end

  def update(_params, _config_overrides), do: {:error, ":id and :event are required"}

  defp handle_response({:ok, %{status: 200, body: result}}, origin)
       when origin in [:create, :update],
       do: {:ok, parse(result)}

  defp handle_response({:ok, %{status: 200, body: %{"results" => result}}}, :all),
    do: {:ok, Enum.map(result, &parse/1)}

  defp handle_response({:error, _reason} = error, _caller), do: error

  defp parse(webhook) do
    %__MODULE__{
      id: webhook["id"],
      event: webhook["event"],
      url: webhook["url"],
      created_at: NaiveDateTime.from_iso8601!(webhook["createdAt"]),
      updated_at: NaiveDateTime.from_iso8601!(webhook["updatedAt"])
    }
  end
end
