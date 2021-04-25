defmodule PluggyElixir.HttpAdapter.Response do
  @moduledoc """
  This module defines a `PluggyElixir.HttpAdapter.Response.t/0` struct that stores http responses.
  """

  @type body :: any()
  @type headers :: [{binary(), binary()}]
  @type status :: integer() | nil

  @type t :: %__MODULE__{
          body: body(),
          headers: headers(),
          status: status()
        }

  defstruct [:body, :headers, :status]
end
