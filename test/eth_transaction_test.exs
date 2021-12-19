defmodule EthTransactionTest do
  use ExUnit.Case

  alias EthTransaction.Cache
  alias EthTransaction.MockBlockNative
  alias EthTransaction.MockSlack

  import Mox
  setup [:clear_on_exit, :verify_on_exit!]

  describe "EthTransaction.create/1" do
    test "Success when transaction cached" do
      # setup
      txs_hash = generate_dummy_tx_hash()
      stub(MockBlockNative, :watch_tx, fn _ -> {:ok, :response} end)
      stub(MockSlack, :webhook_post, fn _, _ -> {:ok, :response} end)

      assert txs_hash |> EthTransaction.create() |> is_list()
    end
  end

  describe "EthTransaction.fetch_transactions/1" do
    test "Return empty list of pending transactions" do
      assert is_list(EthTransaction.fetch_transactions("pending"))
    end

    test "Return empty list transactions" do
      assert is_list(EthTransaction.fetch_transactions(""))
    end

    test "Return list of pending transactions" do
      for _ <- 1..5 do
        Cache.update_transaction("pending", generate_dummy_tx_hash(), false)
      end

      pending_txs = EthTransaction.fetch_transactions("pending")
      assert is_list(pending_txs)
      assert length(pending_txs) == 5
      refute is_nil(Enum.find(pending_txs, fn tx -> tx.status == "pending" end))
    end

    test "Return list of all transactions" do
      # setup
      status = ~w(pending initiated confirmed)

      for _ <- 1..5 do
        Cache.update_transaction(Enum.random(status), generate_dummy_tx_hash(), false)
      end

      all_txs = EthTransaction.fetch_transactions("")
      assert is_list(all_txs)
      assert length(all_txs) == 5
      refute is_nil(Enum.find(all_txs, fn tx -> tx.status in status end))
    end
  end

  defp clear_on_exit(_context) do
    :sys.replace_state(Cache, fn _ -> %{} end)
  end

  def generate_dummy_tx_hash(length \\ 50) do
    rand_string =
      :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)

    "0x" <> rand_string
  end
end
