defmodule EthTransactionWeb.Router do
  use EthTransactionWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", EthTransactionWeb do
    pipe_through(:api)

    post("/transactions", TransactionController, :create)
    get("/transactions", TransactionController, :fetch_all)

    post("/transactions/webhook-stats", TransactionController, :webhook_stats)
  end
end
