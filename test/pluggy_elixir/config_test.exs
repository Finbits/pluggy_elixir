defmodule PluggyElixir.ConfigTest do
  use ExUnit.Case, async: true

  alias PluggyElixir.Config
  alias PluggyElixir.Config.{Adapter, Auth}

  describe "override/1" do
    test "when has a empty list to override return a %Config{} by config files" do
      config = Config.override([])

      assert config ==
               %Config{
                 adapter: %Adapter{
                   configs: [adapter: Tesla.Adapter.Hackney],
                   module: PluggyElixir.HttpAdapter.Tesla
                 },
                 auth: %Auth{
                   api_key: nil,
                   client_id: "test_client_id",
                   client_secret: "test_client_secret",
                   non_expiring_api_key: true,
                   scope: "pluggy_elixir"
                 },
                 host: %URI{
                   authority: nil,
                   fragment: nil,
                   host: "localhost",
                   path: nil,
                   port: 54_321,
                   query: nil,
                   scheme: "http",
                   userinfo: nil
                 },
                 sandbox: true
               }
    end

    test "override config files and return a %Config{}" do
      config =
        Config.override(
          host: "https://customhost.com:4334/api/v1",
          sandbox: false,
          client_id: "auth_client_id",
          client_secret: "auth_client_secret",
          non_expiring_api_key: false,
          api_key: "already_created_api_key",
          scope: "auth_scope_test"
        )

      assert config ==
               %Config{
                 adapter: %Adapter{
                   configs: [adapter: Tesla.Adapter.Hackney],
                   module: PluggyElixir.HttpAdapter.Tesla
                 },
                 auth: %Auth{
                   api_key: "already_created_api_key",
                   client_id: "auth_client_id",
                   client_secret: "auth_client_secret",
                   non_expiring_api_key: false,
                   scope: "auth_scope_test"
                 },
                 host: %URI{
                   authority: nil,
                   fragment: nil,
                   host: "customhost.com",
                   path: "api/v1",
                   port: 4334,
                   query: nil,
                   scheme: "https",
                   userinfo: nil
                 },
                 sandbox: false
               }
    end

    test "ensure boolean values" do
      config =
        Config.override(
          sandbox: "non boolean vaue",
          non_expiring_api_key: "null"
        )

      assert %Config{sandbox: false, auth: %Auth{non_expiring_api_key: false}} = config
    end
  end
end
