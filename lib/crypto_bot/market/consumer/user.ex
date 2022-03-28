defmodule CryptoBot.Market.Consumer.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "users" do
    field :id, :string
    field :state, :string
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :state])
    |> validate_required([:id, :state])
  end
end
