# PluggyElixir

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/Finbits/pluggy_elixir/CI?style=flat-square)](https://github.com/Finbits/pluggy_elixir/actions?query=workflow%3ACI)
[![Hex.pm](https://img.shields.io/hexpm/v/pluggy_elixir?style=flat-square)](https://hex.pm/packages/pluggy_elixir)
[![Hex.pm](https://img.shields.io/hexpm/l/pluggy_elixir?style=flat-square)](https://hex.pm/packages/pluggy_elixir)
[![Hex.pm](https://img.shields.io/hexpm/dt/pluggy_elixir?style=flat-square)](https://hex.pm/packages/pluggy_elixir)
[![codecov](https://img.shields.io/codecov/c/github/Finbits/pluggy_elixir?style=flat-square)](https://codecov.io/gh/Finbits/pluggy_elixir)

Welcome to Pluggy Elixir, an API client written in Elixir to access the Open Finance services provided by [Pluggy](http://pluggy.ai)

## Installation

Add `pluggy_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pluggy_elixir, "~> 0.0.1"}
  ]
end
```

Update deps

```sh
mix deps.get
```

Add the credentials to your config file (ex: `config.exs`)

```elixir
config :pluggy_elixir,
  client_id: "your-app-client-id",
  client_secret: "your-app-client-secret",
```

See more about configurations in `PluggyElixir.Config` docs.

## Use cases

### Register
<table>
<tr>
<th> Data </th>
<th> Use Cases </th>
</tr>
<tr>
<td>

```
{
  full_name,
  tax_id,
  date_of_bird,
  address,
  phone_numbers
}
```
</td>
<td>
<li>Onboarding</li>
<li>Registration</li>
<li>KYC</li>
<li>Customer segmentation</li>
</td>
</tr>
</table>

### Checking account
<table>
<tr>
<th> Data </th>
<th> Use Cases </th>
</tr>
<tr>
<td>

```
{
  balances,
  transactions: [
    {
      date,
      values,
      description,
      type,
      category
    }
  ]
}
```
</td>
<td>
<li>Income analysis</li>
<li>Consumption profile</li>
<li>Financial management</li>
<li>Risk modeling</li>
<li>Financial monitoring</li>
<li>Investment capacity</li>
</td>
</tr>
</table>

### Credit card
<table>
<tr>
<th> Data </th>
<th> Use Cases </th>
</tr>
<tr>
<td>

```
{
  limits,
  minimum_payment,
  brand,
  segment,
  maturity,
  transactions
}
```
</td>
<td>
<li>Consumption profile</li>
<li>Financial management</li>
<li>Credit taking capacity</li>
<li>Financial monitoring</li>
<li>Expenses by category</li>
<li>Consumption cycles</li>
<li>Recurring expenses</li>
</td>
</tr>
</table>

### Investments
<table>
<tr>
<th> Data </th>
<th> Use Cases </th>
</tr>
<tr>
<td>

```
{
  assets,
  code,
  type,
  quantity,
  value,
  historical_profitability,
  taxes,
  index,
  balance_at_the_broker,
  handling_at_the_broker
}
```
</td>
<td>
<li>Portfolio Consolidation</li>
<li>Financial Profile</li>
<li>Transaction monitoring</li>
<li>Investment capacity analysis</li>
<li>Portfolio risk analysis</li>
<li>Investment automation</li>
</td>
</tr>
</table>

### Plugged Institutions
<table>
<tr>
<th> Banks </th>
<th> Investment brokers </th>
</tr>
<tr>
<td>
<li>Itaú (Personal e Corporate)</li>
<li>Bradesco (Personal e Corporate)</li>
<li>Nubank (Personal)</li>
<li>Santander (Personal e Corporate)</li>
<li>Banco do Brasil (Personal e Corporate)</li>
<li>Caixa (Personal e Corporate)</li>
<li>Inter (Personal e Corporate)</li>
<li>Modal Mais (Personal)</li>
<li>BTG Pactual (Personal)</li>
<li>Mercado Pago (Personal)</li>
</td>
<td>
<li>XP Investimentos</li>
<li>Rico</li>
<li>Easynvest</li>
<li>Órama</li>
<li>Genial</li>
<li>Agora</li>
</td>
</tr>
</table>

## API spec

For most up-to-date and accurate documentation, please see the [API Spec](https://docs.pluggy.ai) page.

## Contributing

[Contributing Guide](CONTRIBUTING.md)

## License

[Apache License, Version 2.0](LICENSE) © [Finbits](https://github.com/Finbits)
