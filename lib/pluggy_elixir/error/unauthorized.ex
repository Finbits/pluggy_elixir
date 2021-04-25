defmodule PluggyElixir.Error.Unauthorized do
  @moduledoc """
  Error for invalid credentials.
  """

  @type t :: %__MODULE__{
          message: binary()
        }

  defstruct [:message]
end
