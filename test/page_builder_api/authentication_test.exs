defmodule PageBuilderApi.AuthenticationTest do
  use PageBuilderApi.DataCase

  alias PageBuilderApi.Authentication
  alias PageBuilderApi.Authentication.User

  @valid_attrs %{email: "test@example.com", password: "password123"}
  @update_attrs %{email: "updated@example.com"}

  def user_fixture(attrs \\ %{})

  def user_fixture(attrs) do
    {:ok, user, _token} =
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
    test "with valid credentials creates user and returns token" do
      assert {:ok, user, token} = Authentication.register(@valid_attrs)
      assert user.email == "test@example.com"
      assert is_binary(token)
      assert String.length(token) > 0
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
    test "with valid credentials returns user and token" do
      user_fixture()
      assert {:ok, user, token} = Authentication.login("test@example.com", "password123")
      assert user.email == "test@example.com"
      assert is_binary(token)
    end

    test "with invalid email returns error" do
      assert {:error, :unauthorized} = Authentication.login("wrong@example.com", "password123")
    end

    test "with invalid password returns error" do
      user_fixture()
      assert {:error, :unauthorized} = Authentication.login("test@example.com", "wrongpassword")
    end
  end
end
