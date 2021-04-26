defmodule PluggyElixir.HttpClient.Error do
  @moduledoc """
  Parse API error responses.
  """

  defstruct [:message, :code, :details]

  alias PluggyElixir.HttpAdapter.Response

  @type t() :: %__MODULE__{
          message: binary(),
          code: integer(),
          details: any()
        }

  @doc """
  Return an Error struct by given response
  """

  @spec parse(Response.t()) :: t()
  def parse(%Response{} = response) do
    case response do
      %{status: code, body: %{"message" => message}} ->
        %__MODULE__{message: message, code: code}
    end
  end
end
