defmodule PluggyElixir.HttpClient.ErrorTest do
  use ExUnit.Case, async: true

  alias PluggyElixir.HttpClient.Error
  alias PluggyElixir.HttpAdapter.Response

  describe "parse/1" do
    test "parse an unauthorized error" do
      response = %Response{
        status: 401,
        body: %{"message" => "Client keys are invalid", "code" => 401}
      }

      assert Error.parse(response) == %Error{message: "Client keys are invalid", code: 401}
    end

    test "parse a forbidden error" do
      response = %Response{
        status: 403,
        body: %{"message" => "Forbidden"}
      }

      assert Error.parse(response) == %Error{message: "Forbidden", code: 403}
    end
  end
end
