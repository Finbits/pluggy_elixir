defmodule PluggyElixir.ConfigTest do
  use ExUnit.Case, async: false

  alias PluggyElixir.Config

  setup do
    config = Application.get_all_env(:pluggy_elixir)

    on_exit(fn ->
      Application.put_all_env(pluggy_elixir: config)
    end)

    :ok
  end

  describe "get_client_id/0" do
    test "return configured client id" do
      assert Config.get_client_id() == {:ok, "test_client_id"}
    end

    test "return error if client_id is not configured" do
      Application.delete_env(:pluggy_elixir, :client_id)

      assert Config.get_client_id() ==
               {:error, "Missing PluggyElixir configuration: [ client_id ]"}
    end
  end

  describe "get_client_secret/0" do
    test "return configured client secret" do
      assert Config.get_client_secret() == {:ok, "test_client_secret"}
    end

    test "return error if client_secret is not configured" do
      Application.delete_env(:pluggy_elixir, :client_secret)

      assert Config.get_client_secret() ==
               {:error, "Missing PluggyElixir configuration: [ client_secret ]"}
    end
  end

  describe "get_host_uri/0" do
    test "return a URI struct by parsing configured value" do
      assert Config.get_host_uri() == %URI{
               scheme: "http",
               host: "localhost",
               port: 1234
             }
    end

    test "return default value when not configured" do
      Application.delete_env(:pluggy_elixir, :host)

      assert Config.get_host_uri() == %URI{
               scheme: "https",
               host: "api.pluggy.ai"
             }
    end

    test "parse full url" do
      Application.put_env(:pluggy_elixir, :host, "http://host.com:5000/api")

      assert Config.get_host_uri() == %URI{
               scheme: "http",
               host: "host.com",
               port: 5000,
               path: "api"
             }
    end
  end

  describe "non_expiring_api_key/0" do
    test "return configured value" do
      assert Config.non_expiring_api_key() == true
    end

    test "return default value false when not configured" do
      Application.delete_env(:pluggy_elixir, :non_expiring_api_key)

      assert Config.non_expiring_api_key() == false
    end

    test "return default value false when configured value is invalid" do
      Application.put_env(:pluggy_elixir, :non_expiring_api_key, "yes")

      assert Config.non_expiring_api_key() == false
    end
  end

  describe "sandbox/0" do
    test "return configured value" do
      assert Config.sandbox() == true
    end

    test "return default value false when not configured" do
      Application.delete_env(:pluggy_elixir, :sandbox)

      assert Config.sandbox() == false
    end

    test "return default value false when configured value is invalid" do
      Application.put_env(:pluggy_elixir, :sandbox, "yes")

      assert Config.sandbox() == false
    end
  end
end
