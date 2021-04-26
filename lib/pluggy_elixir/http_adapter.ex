defmodule PluggyElixir.HttpAdapter do
  @moduledoc """
  The HTTP Adapter specification.

  An HttpAdapter is a module that perform HTTP requests and put response into
  `PluggyElixir.HttpAdapter.Response` struct.
  """

  alias PluggyElixir.HttpAdapter.Response

  @type url :: binary()
  @type param :: binary() | [{binary() | atom(), param()}]
  @type query() :: [{binary() | atom(), param()}]
  @type adapter_response :: {:ok, Response.t()} | {:error, binary()}

  @doc "Perform a HTTP request with GET method"
  @callback get(url, query) :: adapter_response()

  @doc "Perform a HTTP request with POST method"
  @callback post(url, Response.body(), query) :: adapter_response()
end