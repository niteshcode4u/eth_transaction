import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :eth_transaction, EthTransactionWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "47uJAkpxJ0b8enHZ0UGGiAltyRJOH7LI/pc9yFQGyuJdZtRG64ypHK95VqHvsaJr",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
