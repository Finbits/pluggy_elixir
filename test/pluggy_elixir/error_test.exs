defmodule PluggyElixir.ErrorTest do
  use ExUnit.Case, async: true

  alias PluggyElixir.Error
  alias PluggyElixir.Error.Unauthorized
  alias PluggyElixir.HttpAdapter.Response

  describe "parse/1" do
    test "paser a unauthorized error" do
      response = %Response{
        status: 401,
        body: %{"message" => "Client keys are invalid", "code" => 401}
      }

      assert Error.parse(response) == %Unauthorized{message: "Client keys are invalid"}
    end
  end
end
