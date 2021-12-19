defmodule EthTransaction.Clients.Blocknative do
  @moduledoc """
  Interface to communicate with Blocknative's API

  Ideally the client_config will return api keys, network, etc...
  """

  require Logger
  alias EthTransaction.HTTP

  @behaviour EthTransaction.Behaviors.BlocknativeClient
  @client_config Application.compile_env!(:eth_transaction, :blocknative)
  @headers [{"Content-Type", "application/json"}]

  @impl true
  def watch_tx(tx_hash) do
    request_body =
      Jason.encode!(%{
        apiKey: @client_config.api_key,
        hash: tx_hash,
        blockchain: @client_config.blockchain,
        network: @client_config.network
      })

    case HTTP.post(@client_config.mempool_webhook_url, request_body, @headers) do
      {:ok, response} ->
        {:ok, response}

      {:error, error} ->
        Logger.error(
          "Received error trying to watch #{inspect(tx_hash)} with reason #{inspect(error)}"
        )

        {:error, error}
    end
  end
end
