defmodule PageBuilderApi.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias PageBuilderApi.Repo
  alias PageBuilderApi.Auth.User
  alias PageBuilderApi.Auth.RefreshToken
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

  Returns {:ok, user, access_token, refresh_token} if credentials are valid.
  Returns {:error, :unauthorized} if credentials are invalid.

  ## Examples

      iex> login("user@example.com", "password123")
      {:ok, %User{}, "access_token...", "refresh_token..."}

      iex> login("user@example.com", "wrongpassword")
      {:error, :unauthorized}

  """
  def login(email, password) when is_binary(email) and is_binary(password) do
    with %User{} = user <- get_user_by_email(email),
         true <- Bcrypt.verify_pass(password, user.password_hash),
         {:ok, access_token, _claims} <- create_access_token(user),
         {:ok, refresh_token} <- create_refresh_token(user) do
      {:ok, user, access_token, refresh_token.token}
    else
      _ -> {:error, :unauthorized}
    end
  end

  @doc """
  Registers a new user with email and password.

  Returns {:ok, user, access_token, refresh_token} if registration is successful.
  Returns {:error, changeset} if validation fails.

  ## Examples

      iex> register(%{email: "user@example.com", password: "password123"})
      {:ok, %User{}, "access_token...", "refresh_token..."}

      iex> register(%{email: "invalid", password: "short"})
      {:error, %Ecto.Changeset{}}

  """
  def register(attrs \\ %{}) do
    with {:ok, user} <- create_user(attrs),
         {:ok, access_token, _claims} <- create_access_token(user),
         {:ok, refresh_token} <- create_refresh_token(user) do
      {:ok, user, access_token, refresh_token.token}
    end
  end

  @doc """
  Refreshes an access token using a valid refresh token.

  Returns {:ok, access_token, refresh_token} if the refresh token is valid.
  Returns {:error, reason} if the refresh token is invalid, expired, or revoked.

  ## Examples

      iex> refresh("valid_refresh_token")
      {:ok, "new_access_token...", "new_refresh_token..."}

      iex> refresh("invalid_token")
      {:error, :invalid_token}

  """
  def refresh(refresh_token_string) when is_binary(refresh_token_string) do
    with {:ok, refresh_token} <- get_valid_refresh_token(refresh_token_string),
         {:ok, user} <- get_user(refresh_token.user_id) |> validate_user_exists(),
         {:ok, _} <- revoke_refresh_token(refresh_token),
         {:ok, access_token, _claims} <- create_access_token(user),
         {:ok, new_refresh_token} <- create_refresh_token(user) do
      {:ok, access_token, new_refresh_token.token}
    end
  end

  @doc """
  Logs out a user by revoking the given refresh token.

  Returns {:ok, :logged_out} if successful.
  Returns {:error, reason} if the token is invalid.

  ## Examples

      iex> logout("valid_refresh_token")
      {:ok, :logged_out}

      iex> logout("invalid_token")
      {:error, :invalid_token}

  """
  def logout(refresh_token_string) when is_binary(refresh_token_string) do
    case get_refresh_token_by_token(refresh_token_string) do
      nil ->
        {:error, :invalid_token}

      %RefreshToken{revoked_at: revoked_at} when not is_nil(revoked_at) ->
        {:error, :invalid_token}

      refresh_token ->
        case revoke_refresh_token(refresh_token) do
          {:ok, _} -> {:ok, :logged_out}
          error -> error
        end
    end
  end

  @doc """
  Logs out a user from all devices by revoking all their refresh tokens.

  Returns {:ok, count} where count is the number of tokens revoked.

  ## Examples

      iex> logout_all(user)
      {:ok, 3}

  """
  def logout_all(%User{} = user) do
    now = utc_now()

    {count, _} =
      from(rt in RefreshToken,
        where: rt.user_id == ^user.id and is_nil(rt.revoked_at)
      )
      |> Repo.update_all(set: [revoked_at: now])

    {:ok, count}
  end

  # Private functions

  defp utc_now, do: DateTime.utc_now() |> DateTime.truncate(:second)

  defp get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  defp create_user(attrs) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  defp create_access_token(%User{} = user) do
    # Short-lived access token (1 hour)
    Guardian.encode_and_sign(user, %{}, ttl: {1, :hour})
  end

  defp create_refresh_token(%User{} = user) do
    RefreshToken.create_changeset(user.id)
    |> Repo.insert()
  end

  defp get_refresh_token_by_token(token) when is_binary(token) do
    Repo.get_by(RefreshToken, token: token)
  end

  defp get_valid_refresh_token(token) when is_binary(token) do
    now = DateTime.utc_now()

    case get_refresh_token_by_token(token) do
      nil ->
        {:error, :invalid_token}

      %RefreshToken{revoked_at: revoked_at} when not is_nil(revoked_at) ->
        {:error, :token_revoked}

      %RefreshToken{expires_at: expires_at} = refresh_token ->
        if DateTime.compare(now, expires_at) == :lt do
          {:ok, refresh_token}
        else
          {:error, :token_expired}
        end
    end
  end

  defp validate_user_exists(nil), do: {:error, :user_not_found}
  defp validate_user_exists(user), do: {:ok, user}

  defp revoke_refresh_token(%RefreshToken{} = refresh_token) do
    refresh_token
    |> RefreshToken.changeset(%{revoked_at: utc_now()})
    |> Repo.update()
  end
end
