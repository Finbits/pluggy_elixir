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
           url: "https://yourapp.com.br/webhook"
         }
       ]}
  """

  @spec all(Config.config_overrides()) :: {:ok, [t()]} | {:error, PluggyElixir.Error.t()}

  def all(config_overrides \\ []) do
    @webhooks_path
    |> HttpClient.get(Config.override(config_overrides))
    |> handle_response()
  end

  defp handle_response({:ok, %{status: 200, body: %{"results" => result}}}),
    do: {:ok, Enum.map(result, &parse/1)}

  defp handle_response({:error, _reason} = error), do: error

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
