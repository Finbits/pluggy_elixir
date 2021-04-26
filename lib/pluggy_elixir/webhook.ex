defmodule PluggyElixir.Webhook do
  alias PluggyElixir.HttpClient

  defstruct [:created_at, :event, :id, :updated_at, :url]

  @type t() :: %__MODULE__{
          event: binary(),
          created_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          id: binary(),
          url: binary()
        }

  @webhooks_path "/webhooks"

  @spec all :: {:ok, [t()]} | {:error, PluggyElixir.Error.t()}
  def all do
    @webhooks_path
    |> HttpClient.get()
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
