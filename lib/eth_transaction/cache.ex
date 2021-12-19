defmodule EthTransaction.Cache do
  @moduledoc """
  Module which handles everything related to trasactions and manages its state
  """
  use GenServer

  ##############################################################################
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Initialize the state of the transactions
  """
  @impl GenServer
  def init(eth_txs), do: {:ok, eth_txs}

  ###############################################################################
  #######################           Public APIs           #######################
  ###############################################################################

  def add_transaction(cache \\ __MODULE__, status, tx_hash) do
    GenServer.cast(cache, {:update_tx, status, tx_hash, false})
  end

  def update_transaction(cache \\ __MODULE__, status, tx_hash, alert_sent?) do
    GenServer.cast(cache, {:update_tx, status, tx_hash, alert_sent?})
  end

  def fetch_transaction(cache \\ __MODULE__, tx_hash) do
    GenServer.call(cache, {:fetch_tx, tx_hash})
  end

  def fetch_transactions(cache \\ __MODULE__) do
    GenServer.call(cache, :fetch_txs)
  end

  def fetch_pending_transactions(cache \\ __MODULE__) do
    GenServer.call(cache, :fetch_pending_txs)
  end

  ###############################################################################
  #######################           Call handlers           #####################
  ###############################################################################

  @impl GenServer
  def handle_cast({:update_tx, status, tx_hash, alert_sent?}, txs) do
    transaction = %{tx_hash: tx_hash, status: status, alert_sent?: alert_sent?}
    new_txs = Map.update(txs, tx_hash, transaction, fn _ -> transaction end)

    {:noreply, new_txs}
  end

  @impl GenServer
  def handle_call({:fetch_tx, tx_hash}, _from, txs) do
    {:reply, txs[tx_hash], txs}
  end

  @impl GenServer
  def handle_call(:fetch_txs, _from, txs) do
    {:reply, Map.values(txs), txs}
  end

  @impl GenServer
  def handle_call(:fetch_pending_txs, _from, txs) do
    pending_txs =
      txs
      |> Enum.map(fn {_, tx} -> tx end)
      |> Enum.filter(fn tx -> tx.status == "pending" end)

    {:reply, pending_txs, txs}
  end

  @impl GenServer
  def handle_info({:send_delayed_pending_alert, tx_hash}, txs) do
    {
      :noreply,
      Map.update!(txs, tx_hash, fn _ ->
        EthTransaction.alert_delayed_pending_status(txs[tx_hash])
      end)
    }
  end
end
