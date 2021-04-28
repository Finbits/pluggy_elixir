defmodule PluggyElixir.WebhookTest do
  use PluggyElixir.Case, async: true

  alias PluggyElixir.HttpClient.Error
  alias PluggyElixir.Webhook

  describe "all/0" do
    test "return all created webhooks", %{bypass: bypass} do
      create_and_save_api_key()

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "GET", "/webhooks", fn conn ->
        Conn.resp(
          conn,
          200,
          ~s<{"results":[{"id":"3f1f889b-6efa-4736-8ded-8b14646f79ca","url":"https://finbits.com.br/webhook","event":"item/updated","createdAt":"2021-04-26T17:41:12.093Z","updatedAt":"2021-04-26T17:41:12.093Z"}]}>
        )
      end)

      assert {:ok, webhooks} = Webhook.all(config_overrides)

      assert webhooks == [
               %PluggyElixir.Webhook{
                 created_at: ~N[2021-04-26 17:41:12.093],
                 event: "item/updated",
                 id: "3f1f889b-6efa-4736-8ded-8b14646f79ca",
                 updated_at: ~N[2021-04-26 17:41:12.093],
                 url: "https://finbits.com.br/webhook"
               }
             ]
    end

    test "return an empty list when there is not webhook created", %{bypass: bypass} do
      create_and_save_api_key()
      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "GET", "/webhooks", fn conn ->
        Conn.resp(conn, 200, ~s<{"results":[]}>)
      end)

      assert {:ok, webhooks} = Webhook.all(config_overrides)

      assert webhooks == []
    end

    test "when has error to get webhook list, returns that error", %{bypass: bypass} do
      create_and_save_api_key()
      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "GET", "/webhooks", fn conn ->
        Conn.resp(conn, 500, ~s<{"message":"Internal Server Error"}>)
      end)

      assert Webhook.all(config_overrides) ==
               {:error, %Error{message: "Internal Server Error", code: 500}}
    end
  end

  describe "create/2" do
    test "create a webook", %{bypass: bypass} do
      create_and_save_api_key()

      params = %{
        event: "all",
        url: "https://finbits.com.br/webhook"
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "POST", "/webhooks", fn %{body_params: body} = conn ->
        Conn.resp(
          conn,
          200,
          ~s<{"id": "d619cfde-a8d7-4fe0-a10d-6de488bde4e0", "event": "#{body["event"]}", "url": "#{
            body["url"]
          }", "createdAt": "2020-06-24T21:29:40.300Z", "updatedAt": "2020-06-24T21:29:40.300Z"}>
        )
      end)

      assert {:ok, result} = Webhook.create(params, config_overrides)

      assert result == %Webhook{
               created_at: ~N[2020-06-24 21:29:40.300],
               event: params.event,
               id: "d619cfde-a8d7-4fe0-a10d-6de488bde4e0",
               updated_at: ~N[2020-06-24 21:29:40.300],
               url: params.url
             }
    end

    test "when using an invalid event, returns a bad request error", %{bypass: bypass} do
      create_and_save_api_key()

      invalid_params = %{
        event: "invalid_event",
        url: "https://finbits.com.br/webhook"
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "POST", "/webhooks", fn conn ->
        Conn.resp(
          conn,
          400,
          ~s<{"message": "Invalid event type for webhook", "code": 400}>
        )
      end)

      assert {:error, result} = Webhook.create(invalid_params, config_overrides)

      assert result == %Error{
               code: 400,
               details: nil,
               message: "Invalid event type for webhook"
             }
    end

    test "when using an invalid URL, returns a bad request error", %{bypass: bypass} do
      create_and_save_api_key()

      invalid_params = %{
        event: "all",
        url: "invalid_url"
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "POST", "/webhooks", fn conn ->
        Conn.resp(
          conn,
          400,
          ~s<{"message": "Webhook url is not valid", "code": 400}>
        )
      end)

      assert {:error, result} = Webhook.create(invalid_params, config_overrides)

      assert result == %Error{
               code: 400,
               details: nil,
               message: "Webhook url is not valid"
             }
    end

    test "when using missing params, returns a validation error" do
      invalid_params = %{}

      assert Webhook.create(invalid_params) == {:error, ":event and :url are required"}
    end

    test "when has error to create webhook, returns that error", %{bypass: bypass} do
      create_and_save_api_key()

      params = %{
        event: "all",
        url: "https://finbits.com.br/webhook"
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "POST", "/webhooks", fn conn ->
        Conn.resp(
          conn,
          500,
          ~s<{"message":"Internal Server Error"}>
        )
      end)

      assert {:error, result} = Webhook.create(params, config_overrides)

      assert result == %Error{
               code: 500,
               details: nil,
               message: "Internal Server Error"
             }
    end
  end

  describe "update/2" do
    test "update a webook", %{bypass: bypass} do
      create_and_save_api_key()

      id = "webhook_id"

      params = %{
        id: id,
        event: "all",
        url: "https://finbits.com.br/updated_webhook"
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "PATCH", "/webhooks/:id", fn %{body_params: body} = conn ->
        assert conn.params["id"] == id

        Conn.resp(
          conn,
          200,
          ~s<{"id": "#{id}", "event": "#{body["event"]}", "url": "#{body["url"]}", "createdAt": "2020-06-24T21:29:40.300Z", "updatedAt": "2020-06-24T21:29:40.300Z"}>
        )
      end)

      assert {:ok, result} = Webhook.update(params, config_overrides)

      assert result == %Webhook{
               created_at: ~N[2020-06-24 21:29:40.300],
               event: params.event,
               id: id,
               updated_at: ~N[2020-06-24 21:29:40.300],
               url: params.url
             }
    end

    test "when using an invalid event, returns a bad request error", %{bypass: bypass} do
      create_and_save_api_key()

      invalid_params = %{
        id: "someid",
        event: "invalid_event",
        url: "https://finbits.com.br/webhook"
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "PATCH", "/webhooks/:id", fn conn ->
        Conn.resp(
          conn,
          400,
          ~s<{"message": "Invalid event type for webhook", "code": 400}>
        )
      end)

      assert {:error, result} = Webhook.update(invalid_params, config_overrides)

      assert result == %Error{
               code: 400,
               details: nil,
               message: "Invalid event type for webhook"
             }
    end

    test "when using an invalid URL, returns a bad request error", %{bypass: bypass} do
      create_and_save_api_key()

      invalid_params = %{
        id: "someid",
        event: "all",
        url: "invalid_url"
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "PATCH", "/webhooks/:id", fn conn ->
        Conn.resp(
          conn,
          400,
          ~s<{"message": "Webhook url is not valid", "code": 400}>
        )
      end)

      assert {:error, result} = Webhook.update(invalid_params, config_overrides)

      assert result == %Error{
               code: 400,
               details: nil,
               message: "Webhook url is not valid"
             }
    end

    test "when missing params, returns a validation error" do
      invalid_params = %{}

      assert Webhook.update(invalid_params) == {:error, ":id and :event are required"}
    end

    test "when has error to update webhook, returns that error", %{bypass: bypass} do
      create_and_save_api_key()

      id = "someid"

      params = %{
        id: id,
        event: "all",
        url: "https://finbits.com.br/webhook"
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      bypass_expect(bypass, "PATCH", "/webhooks/:id", fn conn ->
        assert conn.params["id"] == id

        Conn.resp(
          conn,
          500,
          ~s<{"message":"Internal Server Error"}>
        )
      end)

      assert {:error, result} = Webhook.update(params, config_overrides)

      assert result == %Error{
               code: 500,
               details: nil,
               message: "Internal Server Error"
             }
    end
  end
end
