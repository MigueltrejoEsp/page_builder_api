defmodule PageBuilderApiWeb.AuthControllerTest do
  use PageBuilderApiWeb.ConnCase

  alias PageBuilderApi.Authentication

  @create_attrs %{
    email: "test@example.com",
    password: "password123"
  }

  @invalid_attrs %{email: "invalid", password: "short"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register" do
    test "renders user and token when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", @create_attrs)
      assert %{"data" => data} = json_response(conn, 201)
      assert %{"user" => user, "token" => token} = data
      assert user["email"] == "test@example.com"
      assert is_binary(token)
      assert String.length(token) > 0
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when email is already taken", %{conn: conn} do
      # Create first user
      post(conn, ~p"/api/auth/register", @create_attrs)

      # Try to create duplicate
      conn = post(conn, ~p"/api/auth/register", @create_attrs)
      assert json_response(conn, 422)["errors"]["email"] != nil
    end

    test "renders errors when email format is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", %{email: "notanemail", password: "password123"})
      response = json_response(conn, 422)
      assert response["errors"]["email"] != nil
    end

    test "renders errors when password is too short", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", %{email: "test@example.com", password: "short"})
      response = json_response(conn, 422)
      assert response["errors"]["password"] != nil
    end
  end

  describe "login" do
    setup [:create_user]

    test "renders user and token when credentials are valid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/auth/login", %{email: "test@example.com", password: "password123"})

      assert %{"data" => data} = json_response(conn, 200)
      assert %{"user" => user, "token" => token} = data
      assert user["email"] == "test@example.com"
      assert is_binary(token)
    end

    test "renders error when email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/auth/login", %{email: "wrong@example.com", password: "password123"})

      assert json_response(conn, 401)["error"] == "Invalid email or password"
    end

    test "renders error when password is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/auth/login", %{email: "test@example.com", password: "wrongpassword"})

      assert json_response(conn, 401)["error"] == "Invalid email or password"
    end

    test "renders error when email is missing", %{conn: conn} do
      assert_error_sent 400, fn ->
        post(conn, ~p"/api/auth/login", %{password: "password123"})
      end
    end

    test "renders error when password is missing", %{conn: conn} do
      assert_error_sent 400, fn ->
        post(conn, ~p"/api/auth/login", %{email: "test@example.com"})
      end
    end
  end

  defp create_user(_) do
    {:ok, user, _token} = Authentication.register(@create_attrs)
    %{user: user}
  end
end
