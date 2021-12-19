defmodule EthTransaction.HTTP do
  @moduledoc """
  HTTP client interface
  """

  def post(path, body, opts \\ []) do
    HTTPoison.post(path, body, opts)
  end
end
