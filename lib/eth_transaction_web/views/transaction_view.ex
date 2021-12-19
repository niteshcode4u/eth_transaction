defmodule EthTransactionWeb.TransactionView do
  use EthTransactionWeb, :view

  def render("transactions.json", result) do
    %{transactions: result.transactions}
  end
end
