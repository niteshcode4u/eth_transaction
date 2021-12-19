defmodule EthTransaction do
  @moduledoc """
  EthTransaction keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @success_statuses ~w(confirmed registered)
  @delayed_alert_statuses ~w(pending initiated)
  alias EthTransaction.Cache
  alias EthTransaction.Behaviors.SlackClient
  alias EthTransaction.Behaviors.BlocknativeClient

  def create(txs_hash) do
    for tx_hash <- List.wrap(txs_hash) do
      tx_hash
      |> BlocknativeClient.watch_tx()
      |> case do
        {:ok, _} ->
          # Add tx_hash to state with status initiated
          Cache.add_transaction("initiated", tx_hash)

          send_delayed_pending_alert(tx_hash)

        _ ->
          :invalid_tx_hash
      end
    end
  end

  def fetch_transactions("pending"), do: Cache.fetch_pending_transactions()
  def fetch_transactions(_), do: Cache.fetch_transactions()

  def cache_and_alert(status, tx_hash) when status in @success_statuses do
    SlackClient.webhook_post(tx_hash, status)
    Cache.update_transaction(status, tx_hash, true)
  end

  def cache_and_alert("pending", tx_hash) do
    Cache.update_transaction("pending", tx_hash, false)
    send_delayed_pending_alert(tx_hash)
  end

  # NOTE:  When we don't know the status form BlockNative we are considering it as unknown.
  def cache_and_alert(status, tx_hash),
    do: SlackClient.webhook_post(tx_hash, "Unexpected status: #{status} from BlocknativeAPI.")

  defp send_delayed_pending_alert(tx_hash) do
    Process.send_after(Cache, {:send_delayed_pending_alert, tx_hash}, 2 * 60 * 1000)
  end

  def alert_delayed_pending_status(%{status: status, tx_hash: tx_hash, alert_sent?: false} = tx)
      when status in @delayed_alert_statuses do
    SlackClient.webhook_post(tx_hash, status)

    %{tx | alert_sent?: true, status: "pending"}
  end

  def alert_delayed_pending_status(tx), do: tx
end
