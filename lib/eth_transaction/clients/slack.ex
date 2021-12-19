defmodule EthTransaction.Clients.Slack do
  @moduledoc """
  Interface to communicate with Slack through a webhook

  Ideally the client_config will return api keys or anything else to custommize the request.
  """

  require Logger

  @behaviour EthTransaction.Behaviors.SlackClient

  @caller Application.compile_env!(:eth_transaction, :username)
  @client_config Application.compile_env!(:eth_transaction, :slack_webhook_url)

  alias EthTransaction.HTTP

  @impl true
  def webhook_post(hash, status) do
    body = %{
      text: "*#{hash} got mined*",
      attachments: [
        %{
          blocks: [
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: "*From: #{@caller}*"
              }
            },
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: "*Status: #{String.capitalize(status)}*"
              }
            },
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: "*See on*"
              }
            },
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: "<https://etherscan.com/tx/#{hash}|Etherscan> :male-detective:"
              }
            }
          ]
        }
      ]
    }

    case HTTP.post(@client_config, Jason.encode!(body), [{"Content-Type", "application/json"}]) do
      {:ok, response} ->
        {:ok, response}

      {:error, error} ->
        Logger.error("Received error trying to post to Slack with reason #{inspect(error)}")

        {:error, error}
    end
  end
end
