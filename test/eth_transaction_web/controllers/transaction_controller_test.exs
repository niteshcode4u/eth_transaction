defmodule EthTransactionWeb.TransactionControllerTest do
  use EthTransactionWeb.ConnCase, async: false
  use ExUnit.Case

  alias EthTransaction.Cache
  alias EthTransaction.MockBlockNative
  alias EthTransaction.MockSlack

  import Mox
  setup [:clear_on_exit, :verify_on_exit!]

  describe "GET /api/transactions" do
    test "Return empty list of txs when no tx available", %{conn: conn} do
      resp = get(conn, "/api/transactions")

      assert json_response(resp, 200) == %{"transactions" => []}
    end

    test "Return list of pending transactions if available in cache", %{conn: conn} do
      for _ <- 1..11 do
        EthTransaction.Cache.update_transaction("pending", generate_dummy_tx_hash(), false)
      end

      resp = get(conn, "/api/transactions", %{"status" => "pending"})

      assert %{"transactions" => txs} = json_response(resp, 200)
      assert length(txs) == 11
      refute is_nil(Enum.find(txs, fn tx -> tx["status"] == "pending" end))
    end

    test "Return list of all transactions if available in cache", %{conn: conn} do
      # setup
      status = ~w(pending initiated confirmed)

      for _ <- 1..7 do
        EthTransaction.Cache.update_transaction(
          Enum.random(status),
          generate_dummy_tx_hash(),
          false
        )
      end

      resp = get(conn, "/api/transactions")

      assert %{"transactions" => txs} = json_response(resp, 200)
      assert length(txs) == 7
    end
  end

  describe "POST /api/transactions" do
    test "Return success status once created", %{conn: conn} do
      stub(MockBlockNative, :watch_tx, fn _ -> {:ok, :response} end)

      resp = post(conn, "/api/transactions", %{"txs_hash" => generate_dummy_tx_hash()})

      assert json_response(resp, 200) == %{"status" => "success"}
    end
  end

  describe "POST /api/transactions/webhook-stats" do
    test "Return error in case malformed request received from blocknative", %{conn: conn} do
      resp = post(conn, "/api/transactions/webhook-stats", %{})

      assert resp.status == 400
    end

    test "Return success status if correct request received from blocknative", %{conn: conn} do
      stub(MockBlockNative, :watch_tx, fn _ -> {:ok, :response} end)
      stub(MockSlack, :webhook_post, fn _, _ -> {:ok, :response} end)

      # setup
      tx_hash = generate_dummy_tx_hash()
      EthTransaction.Cache.update_transaction("pending", tx_hash, false)

      resp =
        post(conn, "/api/transactions/webhook-stats", %{
          "status" => "confirmed",
          "hash" => tx_hash
        })

      assert resp.status == 200
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
