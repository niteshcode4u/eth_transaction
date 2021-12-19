ExUnit.start()

Application.ensure_all_started(:mox)

Mox.defmock(EthTransaction.MockBlockNative,
  for: EthTransaction.Behaviors.BlocknativeClient
)

Mox.defmock(EthTransaction.MockSlack,
  for: EthTransaction.Behaviors.SlackClient
)

Application.put_env(
  :eth_transaction,
  :block_native_impl,
  EthTransaction.MockBlockNative
)

Application.put_env(
  :eth_transaction,
  :slack_impl,
  EthTransaction.MockSlack
)
