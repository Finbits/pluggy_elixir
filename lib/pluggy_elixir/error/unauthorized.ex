defmodule PluggyElixir.Error.Unauthorized do
  @moduledoc """
  Error for invalid credentials.
  """

  defstruct [:message]

  @type t :: %__MODULE__{
          message: binary()
        }
end
