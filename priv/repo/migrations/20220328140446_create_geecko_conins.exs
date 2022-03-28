defmodule CryptoBot.Repo.Migrations.CreateGeeckoConins do
  use Ecto.Migration

  def change do
    create table(:geecko_conins, primary_key: false) do
      add :id, :string
      add :name, :string
      add :symbol, :string
      add :inserted_at, :utc_datetime
    end

    create index(:geecko_conins, [:id, :name])
  end
end
