defmodule PageBuilderApi.AuthenticationTest do
  use PageBuilderApi.DataCase

  import Ecto.Query

  alias PageBuilderApi.Authentication
  alias PageBuilderApi.Authentication.User
  alias PageBuilderApi.Repo

  @valid_attrs %{email: "test@example.com", password: "password123"}
  @update_attrs %{email: "updated@example.com"}

  def user_fixture(attrs \\ %{})

  def user_fixture(attrs) do
    {:ok, user, _access_token, _refresh_token} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Authentication.register()

    user
  end

  describe "get_user/1" do
    test "returns the user with given id" do
      user = user_fixture()
      assert Authentication.get_user(user.id).id == user.id
    end

    test "returns nil when user does not exist" do
      assert Authentication.get_user(Ecto.UUID.generate()) == nil
    end
  end

  describe "update_user/2" do
    test "with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = updated_user} = Authentication.update_user(user, @update_attrs)
      assert updated_user.email == "updated@example.com"
    end

    test "with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Authentication.update_user(user, %{email: "invalid"})
      assert user.email == Authentication.get_user(user.id).email
    end
  end

  describe "delete_user/1" do
    test "deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Authentication.delete_user(user)
      assert Authentication.get_user(user.id) == nil
    end
  end

  describe "register/1" do
    test "with valid credentials creates user and returns tokens" do
      assert {:ok, user, access_token, refresh_token} = Authentication.register(@valid_attrs)
      assert user.email == "test@example.com"
      assert is_binary(access_token)
      assert String.length(access_token) > 0
      assert is_binary(refresh_token)
      assert String.length(refresh_token) > 0
    end

    test "with invalid credentials returns error" do
      assert {:error, changeset} = Authentication.register(%{email: "invalid", password: "short"})
      assert %{email: _} = errors_on(changeset)
    end

    test "with invalid email format returns error changeset" do
      assert {:error, changeset} =
               Authentication.register(%{email: "invalid", password: "password123"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "with short password returns error changeset" do
      assert {:error, changeset} =
               Authentication.register(%{email: "test@example.com", password: "short"})

      assert %{password: ["should be at least 8 character(s)"]} = errors_on(changeset)
    end

    test "with duplicate email returns error changeset" do
      user_fixture()
      assert {:error, changeset} = Authentication.register(@valid_attrs)
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "login/2" do
    test "with valid credentials returns user and tokens" do
      user_fixture()

      assert {:ok, user, access_token, refresh_token} =
               Authentication.login("test@example.com", "password123")

      assert user.email == "test@example.com"
      assert is_binary(access_token)
      assert is_binary(refresh_token)
    end

    test "with invalid email returns error" do
      assert {:error, :unauthorized} = Authentication.login("wrong@example.com", "password123")
    end

    test "with invalid password returns error" do
      user_fixture()
      assert {:error, :unauthorized} = Authentication.login("test@example.com", "wrongpassword")
    end
  end

  describe "refresh/1" do
    test "with valid refresh token returns new token pair" do
      {:ok, _user, _access_token, refresh_token} = Authentication.register(@valid_attrs)

      assert {:ok, new_access_token, new_refresh_token} = Authentication.refresh(refresh_token)
      assert is_binary(new_access_token)
      assert is_binary(new_refresh_token)
      assert new_refresh_token != refresh_token
    end

    test "revokes old refresh token after successful refresh" do
      {:ok, _user, _access_token, refresh_token} = Authentication.register(@valid_attrs)

      assert {:ok, _new_access_token, _new_refresh_token} = Authentication.refresh(refresh_token)
      assert {:error, :token_revoked} = Authentication.refresh(refresh_token)
    end

    test "with invalid refresh token returns error" do
      assert {:error, :invalid_token} = Authentication.refresh("invalid_token")
    end

    test "with expired refresh token returns error" do
      {:ok, _user, _access_token, refresh_token} = Authentication.register(@valid_attrs)

      # Manually expire the token by updating the database
      from(rt in PageBuilderApi.Authentication.RefreshToken, where: rt.token == ^refresh_token)
      |> Repo.update_all(set: [expires_at: DateTime.add(DateTime.utc_now(), -1, :day)])

      assert {:error, :token_expired} = Authentication.refresh(refresh_token)
    end

    test "with revoked refresh token returns error" do
      {:ok, _user, _access_token, refresh_token} = Authentication.register(@valid_attrs)

      # Revoke the token
      {:ok, :logged_out} = Authentication.logout(refresh_token)

      assert {:error, :token_revoked} = Authentication.refresh(refresh_token)
    end
  end

  describe "logout/1" do
    test "with valid refresh token revokes it" do
      {:ok, _user, _access_token, refresh_token} = Authentication.register(@valid_attrs)

      assert {:ok, :logged_out} = Authentication.logout(refresh_token)
      assert {:error, :token_revoked} = Authentication.refresh(refresh_token)
    end

    test "with invalid refresh token returns error" do
      assert {:error, :invalid_token} = Authentication.logout("invalid_token")
    end

    test "with already revoked token returns error" do
      {:ok, _user, _access_token, refresh_token} = Authentication.register(@valid_attrs)

      assert {:ok, :logged_out} = Authentication.logout(refresh_token)
      assert {:error, :invalid_token} = Authentication.logout(refresh_token)
    end
  end

  describe "logout_all/1" do
    test "revokes all refresh tokens for a user" do
      {:ok, user, _access_token1, refresh_token1} = Authentication.register(@valid_attrs)

      {:ok, _user, _access_token2, refresh_token2} =
        Authentication.login("test@example.com", "password123")

      {:ok, _user, _access_token3, refresh_token3} =
        Authentication.login("test@example.com", "password123")

      assert {:ok, 3} = Authentication.logout_all(user)

      # All tokens should be revoked
      assert {:error, :token_revoked} = Authentication.refresh(refresh_token1)
      assert {:error, :token_revoked} = Authentication.refresh(refresh_token2)
      assert {:error, :token_revoked} = Authentication.refresh(refresh_token3)
    end

    test "returns count of 0 when user has no refresh tokens" do
      user = user_fixture()

      # Revoke all existing tokens first
      {:ok, _count} = Authentication.logout_all(user)

      assert {:ok, 0} = Authentication.logout_all(user)
    end

    test "does not affect other users' tokens" do
      {:ok, user1, _access_token1, refresh_token1} = Authentication.register(@valid_attrs)

      {:ok, _user2, _access_token2, refresh_token2} =
        Authentication.register(%{email: "other@example.com", password: "password123"})

      assert {:ok, 1} = Authentication.logout_all(user1)

      # user1's token should be revoked
      assert {:error, :token_revoked} = Authentication.refresh(refresh_token1)

      # user2's token should still be valid
      assert {:ok, _new_access, _new_refresh} = Authentication.refresh(refresh_token2)
    end
  end
end
