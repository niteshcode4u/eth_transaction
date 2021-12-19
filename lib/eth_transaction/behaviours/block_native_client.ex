defmodule EthTransaction.Behaviors.BlocknativeClient do
  @moduledoc """
  Blocknative behavior. We can use or ignore this module although it's already implemented.
  """

  @type request_response ::
          {:ok, response :: HTTPoison.Response.t()} | {:error, response :: any()}
  @callback watch_tx(request_body :: map()) :: request_response()

  def watch_tx(tx_hash), do: impl().watch_tx(tx_hash)

  defp impl,
    do:
      Application.get_env(
        :eth_transaction,
        :block_native_impl,
        EthTransaction.Clients.Blocknative
      )
end
