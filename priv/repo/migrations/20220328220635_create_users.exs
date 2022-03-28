defmodule CryptoBot.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :string
      add :state, :string
    end

    create index(:users, [:id])
  end
end
