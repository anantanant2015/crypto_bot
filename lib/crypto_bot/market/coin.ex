defmodule CryptoBot.Market.Coin do
  @moduledoc """
  The CryptoBot.Coin context.
  """

  import Ecto.Query, warn: false
  alias CryptoBot.Repo

  alias CryptoBot.Market.Coin.GeckoCoin

  @doc """
  Returns the list of geecko_conins.

  ## Examples

      iex> list_geecko_conins()
      [%GeckoCoin{}, ...]

  """
  def list_geecko_conins do
    Repo.all(GeckoCoin)
  end

  @doc """
  Gets a single gecko_coin.

  Raises `Ecto.NoResultsError` if the Gecko coin does not exist.

  ## Examples

      iex> get_gecko_coin!(123)
      %GeckoCoin{}

      iex> get_gecko_coin!(456)
      ** (Ecto.NoResultsError)

  """
  def get_gecko_coin!(id), do: Repo.get!(GeckoCoin, id)

  @doc """
  Inserts the list of geecko_conins.

  ## Examples
      iex> coins = [%{
                    id: "01coin",
                    inserted_at: ~U[2022-03-28 16:46:10.886645Z],
                    name: "01coin",
                    symbol: "zoc"
                  }]

      iex> insert_all(coins)
      {1, nil}

  """
  def insert_all(coins) do
    Repo.insert_all(GeckoCoin, coins, on_conflict: :nothing)
  end

  @doc """
  Deletes all the list of geecko_conins.

  ## Examples
      iex> delete_all(coins)
      {1, nil}

  """
  def delete_all() do
    Repo.delete_all(GeckoCoin)
  end

  @doc """
  Returns the last insert date.

  ## Examples

      iex> data_inserted_at()
      ~U[2022-03-28 18:18:54Z]

      iex> data_inserted_at()
      nil

  """
  def data_inserted_at() do
    GeckoCoin
    |> select([gc], gc.inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Gets a coin data with field, and value with limit.

  ## Examples

      iex> search_by(:id, "x")
      [%{
                    id: "01coin",
                    inserted_at: ~U[2022-03-28 16:46:10.886645Z],
                    name: "01coin",
                    symbol: "zoc"
                  }]

      iex> search_by(:id, "!")
      []

  """
  def search_by(field_name, field_value, limit \\ 5) do
    search_expression = "%#{field_value}%"

    GeckoCoin
    |> where([gc], ilike(field(gc, ^field_name), ^search_expression))
    |> select([gc], gc)
    |> limit(^limit)
    |> distinct(true)
    |> Repo.all()
  end
end
