defmodule CryptoBot.CryptoBot.CoinTest do
  use CryptoBot.DataCase

  alias CryptoBot.CryptoBot.Coin

  describe "geecko_conins" do
    alias CryptoBot.CryptoBot.Coin.GeckoCoin

    import CryptoBot.CryptoBot.CoinFixtures

    @invalid_attrs %{id: nil, name: nil, symbol: nil}
  end
end
