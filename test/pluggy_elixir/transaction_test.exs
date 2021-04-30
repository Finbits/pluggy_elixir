defmodule PluggyElixir.TransactionTest do
  use PluggyElixir.Case

  alias PluggyElixir.HttpClient.Error
  alias PluggyElixir.Transaction

  describe "all_by_account/4" do
    test "list transactions of an account and period", %{bypass: bypass} do
      params = %{
        account_id: "d619cfde-a8d7-4fe0-a10d-6de488bde4e0",
        from: ~D[2020-01-01],
        to: ~D[2020-02-01]
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      create_and_save_api_key()

      bypass_expect(bypass, "GET", "/transactions", fn conn ->
        Conn.resp(
          conn,
          200,
          ~s<{"total": 3, "totalPages": 1, "page": 1, "results": [{"id": "5d6b9f9a-06aa-491f-926a-15ba46c6366d", "accountId": "03cc0eff-4ec5-495c-adb3-1ef9611624fc", "description": "Rappi", "currencyCode": "BRL", "amount": 41.58, "date": "2020-06-08T00:00:00.000Z", "balance": 41.58, "category": "Online Payment", "status": "POSTED"}, {"id": "6ec156fe-e8ac-4d9a-a4b3-7770529ab01c", "description": "TED Example", "descriptionRaw": null, "currencyCode": "BRL", "amount": 1500, "date": "2021-04-12T00:00:00.000Z", "balance": 3000, "category": "Transfer", "accountId": "03cc0eff-4ec5-495c-adb3-1ef9611624fc", "providerCode": "123", "status": "POSTED", "paymentData": {"payer": {"name": "Tiago Rodrigues Santos", "branchNumber": "090", "accountNumber": "1234-5", "routingNumber": "001", "documentNumber": {"type": "CPF", "value": "882.937.076-23"}}, "reason": "Taxa de serviço", "receiver": {"name": "Pluggy", "branchNumber": "999", "accountNumber": "9876-1", "routingNumber": "002", "documentNumber": {"type": "CNPJ", "value": "08.050.608/0001-32"}}, "paymentMethod": "TED", "referenceNumber": "123456789"}}]} >
        )
      end)

      assert {:ok, result} = Transaction.all_by_account(params, config_overrides)

      assert_pluggy(%{
        query_params: %{
          "accountId" => "d619cfde-a8d7-4fe0-a10d-6de488bde4e0",
          "from" => "2020-01-01",
          "sandbox" => "true",
          "to" => "2020-02-01",
          "pageSize" => "20",
          "page" => "1"
        }
      })

      assert result == %{
               page: 1,
               total: 3,
               total_pages: 1,
               transactions: [
                 %Transaction{
                   account_id: "03cc0eff-4ec5-495c-adb3-1ef9611624fc",
                   amount: 41.58,
                   balance: 41.58,
                   category: "Online Payment",
                   currency_code: "BRL",
                   date: ~N[2020-06-08 00:00:00.000],
                   description: "Rappi",
                   description_raw: nil,
                   id: "5d6b9f9a-06aa-491f-926a-15ba46c6366d",
                   payment_data: nil,
                   provider_code: nil,
                   status: "POSTED"
                 },
                 %Transaction{
                   account_id: "03cc0eff-4ec5-495c-adb3-1ef9611624fc",
                   amount: 1_500,
                   balance: 3_000,
                   category: "Transfer",
                   currency_code: "BRL",
                   date: ~N[2021-04-12 00:00:00.000],
                   description: "TED Example",
                   description_raw: nil,
                   id: "6ec156fe-e8ac-4d9a-a4b3-7770529ab01c",
                   payment_data: %{
                     payer: %{
                       account_number: "1234-5",
                       branch_number: "090",
                       document_number: %{
                         type: "CPF",
                         value: "882.937.076-23"
                       },
                       routing_number: "001",
                       type: nil
                     },
                     payment_method: "TED",
                     reason: "Taxa de serviço",
                     receiver: %{
                       account_number: "9876-1",
                       branch_number: "999",
                       document_number: %{
                         type: "CNPJ",
                         value: "08.050.608/0001-32"
                       },
                       routing_number: "002",
                       type: nil
                     },
                     reference_number: "123456789"
                   },
                   provider_code: "123",
                   status: "POSTED"
                 }
               ]
             }
    end

    test "allow custom pagination", %{bypass: bypass} do
      params = %{
        account_id: "d619cfde-a8d7-4fe0-a10d-6de488bde4e0",
        from: ~D[2020-01-01],
        to: ~D[2020-02-01],
        page_size: 1,
        page: 2
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      create_and_save_api_key()

      bypass_expect(bypass, "GET", "/transactions", fn conn ->
        Conn.resp(
          conn,
          200,
          ~s<{"total": 3, "totalPages": 3, "page": 2, "results": [{"id": "5d6b9f9a-06aa-491f-926a-15ba46c6366d", "accountId": "03cc0eff-4ec5-495c-adb3-1ef9611624fc", "description": "Rappi", "currencyCode": "BRL", "amount": 41.58, "date": "2020-06-08T00:00:00.000Z", "balance": 41.58, "category": "Online Payment", "status": "POSTED"}]}>
        )
      end)

      assert {:ok, result} = Transaction.all_by_account(params, config_overrides)

      assert_pluggy(%{
        query_params: %{
          "accountId" => "d619cfde-a8d7-4fe0-a10d-6de488bde4e0",
          "from" => "2020-01-01",
          "sandbox" => "true",
          "to" => "2020-02-01",
          "pageSize" => "1",
          "page" => "2"
        }
      })

      assert result == %{
               page: 2,
               total: 3,
               total_pages: 3,
               transactions: [
                 %Transaction{
                   account_id: "03cc0eff-4ec5-495c-adb3-1ef9611624fc",
                   amount: 41.58,
                   balance: 41.58,
                   category: "Online Payment",
                   currency_code: "BRL",
                   date: ~N[2020-06-08 00:00:00.000],
                   description: "Rappi",
                   description_raw: nil,
                   id: "5d6b9f9a-06aa-491f-926a-15ba46c6366d",
                   payment_data: nil,
                   provider_code: nil,
                   status: "POSTED"
                 }
               ]
             }
    end

    test "handle empty results", %{bypass: bypass} do
      params = %{
        account_id: "d619cfde-a8d7-4fe0-a10d-6de488bde4e0",
        from: "invalid-date",
        to: ~D[2020-02-01]
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      create_and_save_api_key()

      bypass_expect(bypass, "GET", "/transactions", fn conn ->
        Conn.resp(conn, 200, ~s<{"total": 0, "totalPages": 0, "page": 1, "results": []}>)
      end)

      assert {:ok, result} = Transaction.all_by_account(params, config_overrides)

      assert result == %{
               page: 1,
               total: 0,
               total_pages: 0,
               transactions: []
             }
    end

    test "when params are invalid, returns a validation error" do
      invalid_params = %{}

      assert Transaction.all_by_account(invalid_params) ==
               {:error, ":account_id, :from, and :to are required"}
    end

    test "when has error to get transactions list, returns that error", %{bypass: bypass} do
      params = %{
        account_id: "invalid-account-id",
        from: "invalid-date",
        to: ~D[2020-02-01]
      }

      config_overrides = [host: "http://localhost:#{bypass.port}"]

      create_and_save_api_key()

      bypass_expect(bypass, "GET", "/transactions", fn conn ->
        Conn.resp(
          conn,
          500,
          ~s<{"message": "There was an error processing your request", "code": 500}>
        )
      end)

      assert {:error, reason} = Transaction.all_by_account(params, config_overrides)

      assert reason == %Error{
               code: 500,
               details: nil,
               message: "There was an error processing your request"
             }
    end
  end
end
