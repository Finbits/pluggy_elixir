defmodule PluggyElixir.Config do
  @moduledoc false

  def get_client_id, do: get_pluggy_elixir_config(:client_id)
  def get_client_secret, do: get_pluggy_elixir_config(:client_secret)

  def non_expiring_api_key,
    do: if(get_pluggy_elixir_config(:non_expiring_api_key, false) == true, do: true, else: false)

  defp get_pluggy_elixir_config(key, default_value \\ :required, custom_message \\ nil) do
    case Application.get_env(:pluggy_elixir, key, default_value) do
      :required -> config_error(key, custom_message)
      value -> config_success(value, default_value)
    end
  end

  defp config_error(key, nil), do: {:error, "Missing PluggyElixir configuration: [ #{key} ]"}

  defp config_success(value, :required), do: {:ok, value}
  defp config_success(value, _no_required), do: value
end
