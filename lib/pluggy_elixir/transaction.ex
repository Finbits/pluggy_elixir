defmodule PluggyElixir.Transaction do
  @moduledoc """
  Handle transactions actions.
  """

  alias PluggyElixir.{Config, HttpClient}

  defstruct [
    :id,
    :description,
    :description_raw,
    :currency_code,
    :amount,
    :date,
    :balance,
    :category,
    :account_id,
    :provider_code,
    :status,
    :payment_data
  ]

  @type t :: %__MODULE__{
          id: binary(),
          description: binary(),
          description_raw: binary(),
          currency_code: binary(),
          amount: float(),
          date: NaiveDateTime.t(),
          balance: float(),
          category: binary(),
          account_id: binary(),
          provider_code: binary(),
          status: binary(),
          payment_data: payment_data()
        }

  @type payment_data :: %{
          payer: identity(),
          receiver: identity(),
          reason: binary(),
          payment_method: binary(),
          reference_number: binary()
        }

  @type identity :: %{
          type: binary(),
          branch_number: binary(),
          account_number: binary(),
          routing_number: binary(),
          document_number: document()
        }

  @type document :: %{
          type: binary(),
          value: binary()
        }

  @transactions_path "/transactions"
  @default_page_size 20
  @default_page_number 1

  @doc """
  List transactions supporting filters (by account and period) and pagination.

  ### Examples

      iex> params = %{
        account_id: "03cc0eff-4ec5-495c-adb3-1ef9611624fc",
        from: ~D[2021-04-01],
        to: ~D[2021-05-01],
        page_size: 100,
        page: 1
      }
      iex> Transaction.all_by_account(params)
      {:ok,
       %{
         page: 1,
         total: 1,
         total_pages: 1,
         transactions: [
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
       }}
  """

  @spec all_by_account(
          %{
            :account_id => String.t(),
            :from => Date.t(),
            :to => Date.t(),
            optional(:page_size) => integer(),
            optional(:page) => integer()
          },
          Config.config_overrides()
        ) ::
          {:ok, %{page: integer(), total_pages: integer(), total: integer(), transactions: [t()]}}
          | {:error, PluggyElixir.HttpClient.Error.t() | String.t()}
  def all_by_account(params, config_overrides \\ [])

  def all_by_account(%{account_id: _, from: _, to: _} = params, config_overrides) do
    @transactions_path
    |> HttpClient.get(format_params(params), Config.override(config_overrides))
    |> handle_response
  end

  def all_by_account(_params, _config_overrides),
    do: {:error, ":account_id, :from, and :to are required"}

  defp handle_response({:ok, %{status: 200, body: body}}) do
    result = %{
      page: body["page"],
      total_pages: body["totalPages"],
      total: body["total"],
      transactions: Enum.map(body["results"], &parse_transaction/1)
    }

    {:ok, result}
  end

  defp handle_response({:error, _reason} = error), do: error

  defp format_params(params) do
    [
      accountId: params[:account_id],
      from: params[:from],
      to: params[:to],
      pageSize: Map.get(params, :page_size, @default_page_size),
      page: Map.get(params, :page, @default_page_number)
    ]
  end

  defp parse_transaction(transaction) do
    %__MODULE__{
      id: transaction["id"],
      description: transaction["description"],
      description_raw: transaction["descriptionRaw"],
      currency_code: transaction["currencyCode"],
      amount: parse_float(transaction["amount"]),
      date: NaiveDateTime.from_iso8601!(transaction["date"]),
      balance: parse_float(transaction["balance"]),
      category: transaction["category"],
      account_id: transaction["accountId"],
      provider_code: transaction["providerCode"],
      status: transaction["status"],
      payment_data: parse_payment_data(transaction["paymentData"])
    }
  end

  defp parse_payment_data(nil), do: nil

  defp parse_payment_data(payment_data) do
    %{
      payer: parse_identity(payment_data["payer"]),
      receiver: parse_identity(payment_data["receiver"]),
      reason: payment_data["reason"],
      payment_method: payment_data["paymentMethod"],
      reference_number: payment_data["referenceNumber"]
    }
  end

  defp parse_identity(identity) do
    %{
      type: identity["type"],
      branch_number: identity["branchNumber"],
      account_number: identity["accountNumber"],
      routing_number: identity["routingNumber"],
      document_number: %{
        type: get_in(identity, ["documentNumber", "type"]),
        value: get_in(identity, ["documentNumber", "value"])
      }
    }
  end

  defp parse_float(number) when is_float(number), do: number
  defp parse_float(number), do: "#{number}" |> Float.parse() |> elem(0)
end
