defmodule CryptoBot.Market.Coin.GeckoCoin do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "geecko_conins" do
    field :id, :string
    field :name, :string
    field :symbol, :string
    field :inserted_at, :utc_datetime
  end

  @doc false
  def changeset(gecko_coin, attrs) do
    gecko_coin
    |> cast(attrs, [:id, :name, :symbol, :inserted_at])
    |> validate_required([:id, :name, :symbol, :inserted_at])
  end
end
