use Mix.Config

bypass_port = 54321

config :bypass, port: bypass_port

config :pluggy_elixir,
  client_id: "test_client_id",
  client_secret: "test_client_secret",
  non_expiring_api_key: true,
  sandbox: true,
  host: "http://localhost:#{bypass_port}"
