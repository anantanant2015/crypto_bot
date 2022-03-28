defmodule CryptoBot.Market.ConsumerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CryptoBot.Market.Consumer` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        id: "some id",
        state: "some state"
      })
      |> CryptoBot.Market.Consumer.create_user()

    user
  end
end
