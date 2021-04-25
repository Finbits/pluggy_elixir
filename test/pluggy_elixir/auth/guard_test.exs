defmodule PluggyElixir.Auth.GuardTest do
  use ExUnit.Case, async: true

  alias PluggyElixir.Auth
  alias PluggyElixir.Auth.Guard

  describe "set_auth/1" do
    test "add a auth value to Agent" do
      auth = %Auth{api_key: "auth_guard_test_add_auth_example"}

      assert Guard.set_auth(auth) == :ok

      assert Enum.any?(:sys.get_state(Guard), fn {_key, value} -> value == auth end)
    end

    test "replace auth value" do
      initial_auth = %Auth{api_key: "auth_guard_test_add_auth_example_initial"}

      new_auth = %Auth{api_key: "auth_guard_test_add_auth_example_new"}

      assert Guard.set_auth(initial_auth) == :ok
      assert Enum.any?(:sys.get_state(Guard), fn {_key, value} -> value == initial_auth end)

      assert Guard.set_auth(new_auth) == :ok
      refute Enum.any?(:sys.get_state(Guard), fn {_key, value} -> value == initial_auth end)
      assert Enum.any?(:sys.get_state(Guard), fn {_key, value} -> value == new_auth end)
    end
  end

  describe "get_auth/0" do
    test "get previous set auth" do
      auth = %Auth{api_key: "auth_guard_test_get_auth_example"}

      :ok = Guard.set_auth(auth)

      assert Guard.get_auth() == auth
    end

    test "get nil when there isnt set value " do
      assert Guard.get_auth() == nil
    end
  end
end
