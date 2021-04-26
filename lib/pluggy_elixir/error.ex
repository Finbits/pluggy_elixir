defmodule PluggyElixir.Error do
  @moduledoc """
  Parse API error responses.
  """

  alias PluggyElixir.Error.Unauthorized
  alias PluggyElixir.HttpAdapter.Response

  @type error :: Unauthorized.t()

  @doc """
  Return an Error struct by given response
  """

  @spec parse(Response.t()) :: error()
  def parse(%Response{} = response) do
    case response do
      %{status: 401, body: %{"message" => message, "code" => 401}} ->
        %Unauthorized{message: message}
    end
  end
end
