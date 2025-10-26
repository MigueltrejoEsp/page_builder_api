defmodule PageBuilderApi.Authentication do
  @moduledoc """
  The Authentication context.
  """

  import Ecto.Query, warn: false
  alias PageBuilderApi.Repo
  alias PageBuilderApi.Authentication.User
  alias PageBuilderApi.Guardian

  @doc """
  Gets a single user by id.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Authenticates a user with email and password.

  Returns {:ok, user, token} if credentials are valid.
  Returns {:error, :unauthorized} if credentials are invalid.

  ## Examples

      iex> login("user@example.com", "password123")
      {:ok, %User{}, "eyJhbGc..."}

      iex> login("user@example.com", "wrongpassword")
      {:error, :unauthorized}

  """
  def login(email, password) when is_binary(email) and is_binary(password) do
    with %User{} = user <- get_user_by_email(email),
         true <- Bcrypt.verify_pass(password, user.password_hash),
         {:ok, token, _claims} <- create_token(user) do
      {:ok, user, token}
    else
      _ -> {:error, :unauthorized}
    end
  end

  @doc """
  Registers a new user with email and password.

  Returns {:ok, user, token} if registration is successful.
  Returns {:error, changeset} if validation fails.

  ## Examples

      iex> register(%{email: "user@example.com", password: "password123"})
      {:ok, %User{}, "eyJhbGc..."}

      iex> register(%{email: "invalid", password: "short"})
      {:error, %Ecto.Changeset{}}

  """
  def register(attrs \\ %{}) do
    with {:ok, user} <- create_user(attrs),
         {:ok, token, _claims} <- create_token(user) do
      {:ok, user, token}
    end
  end

  # Private functions

  defp get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  defp create_user(attrs) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  defp create_token(%User{} = user) do
    Guardian.encode_and_sign(user, %{}, ttl: {30, :days})
  end
end
