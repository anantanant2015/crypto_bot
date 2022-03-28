defmodule CryptoBot.Market.Consumer do
  @moduledoc """
  The Market.Consumer context.
  """

  import Ecto.Query, warn: false
  alias CryptoBot.Repo

  alias CryptoBot.Market.Consumer.User

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user_by(123)
      %User{}

      iex> get_user_by(456)
      nil

  """
  def get_user_by(id), do: Repo.get_by(User, id: id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    User
    |> where([u], u.id == ^attrs.id)
    |> update([u], set: [state: ^attrs.state])
    |> Repo.update_all([])
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{id: id}) do
    User
    |> where([u], u.id == ^id)
    |> Repo.delete_all()
  end
end
