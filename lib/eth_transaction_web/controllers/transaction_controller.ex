defmodule EthTransactionWeb.TransactionController do
  use EthTransactionWeb, :controller

  def create(conn, %{"txs_hash" => txs_hash}) do
    EthTransaction.create(txs_hash)

    conn
    |> put_status(200)
    |> json(%{"status" => "success"})
  end

  def fetch_all(conn, params) do
    render(
      conn,
      "transactions.json",
      transactions: EthTransaction.fetch_transactions(params["status"])
    )
  end

  def webhook_stats(conn, %{"status" => status, "hash" => tx_hash}) do
    # Cache the transaction and alert the status to slack
    EthTransaction.cache_and_alert(status, tx_hash)

    send_resp(conn, 200, "")
  end

  def webhook_stats(conn, _params) do
    send_resp(conn, 400, "")
  end
end
