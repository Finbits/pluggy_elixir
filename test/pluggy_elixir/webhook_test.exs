defmodule PluggyElixir.WebhookTest do
  use PluggyElixir.Case, async: true

  alias PluggyElixir.Webhook

  describe "all/0" do
    test "return all created webhooks", %{bypass: bypass} do
      create_and_save_api_key()

      bypass_expect(bypass, "GET", "/webhooks", fn conn ->
        Conn.resp(
          conn,
          200,
          ~s<{"results":[{"id":"3f1f889b-6efa-4736-8ded-8b14646f79ca","url":"https://finbits.com.br/teste","event":"item/updated","createdAt":"2021-04-26T17:41:12.093Z","updatedAt":"2021-04-26T17:41:12.093Z"}]}>
        )
      end)

      assert {:ok, webhooks} = Webhook.all()

      assert webhooks == [
               %PluggyElixir.Webhook{
                 created_at: ~N[2021-04-26 17:41:12.093],
                 event: "item/updated",
                 id: "3f1f889b-6efa-4736-8ded-8b14646f79ca",
                 updated_at: ~N[2021-04-26 17:41:12.093],
                 url: "https://finbits.com.br/teste"
               }
             ]
    end

    test "return an empty list when there is not webhook created", %{bypass: bypass} do
      create_and_save_api_key()

      bypass_expect(bypass, "GET", "/webhooks", fn conn ->
        Conn.resp(conn, 200, ~s<{"results":[]}>)
      end)

      assert {:ok, webhooks} = Webhook.all()

      assert webhooks == []
    end

    test "when has error to get webhook list, returns that error", %{bypass: bypass} do
      create_and_save_api_key()
      Bypass.down(bypass)

      assert Webhook.all() == {:error, "econnrefused"}
    end
  end
end