defmodule EthTransaction.Behaviors.SlackClient do
  @moduledoc """
  Slack behavior. We can use this or ignore although it's already implemented.
  """
  @type request_response ::
          {:ok, response :: HTTPoison.Response.t()} | {:error, response :: any()}
  @callback webhook_post(String.t(), String.t()) :: request_response()

  def webhook_post(tx_hash, status), do: impl().webhook_post(tx_hash, status)

  defp impl,
    do:
      Application.get_env(
        :eth_transaction,
        :slack_impl,
        EthTransaction.Clients.Slack
      )
end
