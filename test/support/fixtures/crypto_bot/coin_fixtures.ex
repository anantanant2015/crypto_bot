defmodule CryptoBot.CryptoBot.CoinFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CryptoBot.CryptoBot.Coin` context.
  """

  @doc """
  Generate a gecko_coin.
  """
  def gecko_coin_fixture(attrs \\ %{}) do
    {:ok, gecko_coin} =
      attrs
      |> Enum.into(%{
        id: "some id",
        name: "some name",
        symbol: "some symbol"
      })
      |> CryptoBot.CryptoBot.Coin.create_gecko_coin()

    gecko_coin
  end
end
