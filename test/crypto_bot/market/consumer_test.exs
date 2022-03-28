defmodule CryptoBot.Market.ConsumerTest do
  use CryptoBot.DataCase

  alias CryptoBot.Market.Consumer

  describe "users" do
    alias CryptoBot.Market.Consumer.User

    import CryptoBot.Market.ConsumerFixtures

    @invalid_attrs %{id: nil, state: nil}

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{id: "some id", state: "some state"}

      assert {:ok, %User{} = user} = Consumer.create_user(valid_attrs)
      assert user.id == "some id"
      assert user.state == "some state"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Consumer.create_user(@invalid_attrs)
    end
  end
end
