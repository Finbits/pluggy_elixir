defmodule PluggyElixir.HttpAdapter do
  @moduledoc """
  The HTTP Adapter specification.

  An HttpAdapter is a module that perform HTTP requests and put response into
  `PluggyElixir.HttpAdapter.Response` struct.
  """

  alias PluggyElixir.Config
  alias PluggyElixir.HttpAdapter.Response

  @type url :: binary()
  @type body :: Response.body()
  @type headers :: Response.headers()
  @type param :: binary() | [{binary() | atom(), param()}]
  @type query :: [{binary() | atom(), param()}]
  @type adapter_response :: {:ok, Response.t()} | {:error, binary()}

  @doc "Perform a HTTP request with GET method"
  @callback get(url, query, headers(), Config.t()) :: adapter_response()

  @doc "Perform a HTTP request with POST method"
  @callback post(url, body(), query, headers(), Config.t()) :: adapter_response()

  @doc "Perform a HTTP request with PATCH method"
  @callback patch(url, body(), query, headers(), Config.t()) :: adapter_response()
end
