# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :eth_transaction,
  blocknative: %{
    api_key: "300d693e-1e13-47a0-bf0a-5f493aad8663",
    blockchain: "ethereum",
    network: "main",
    mempool_webhook_url: "https://api.blocknative.com/transaction"
  },
  alert_pending_timer: :timer.minutes(2),
  username: "niteshcode4you",
  slack_webhook_url:
    "https://hooks.slack.com/services/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"

# Configures the endpoint
config :eth_transaction, EthTransactionWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: EthTransactionWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: EthTransaction.PubSub,
  live_view: [signing_salt: "SCbbIu+B"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
