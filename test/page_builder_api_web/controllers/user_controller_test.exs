defmodule PageBuilderApiWeb.UserControllerTest do
  use PageBuilderApiWeb.ConnCase

  alias PageBuilderApi.Authentication

  @create_attrs %{
    email: "test@example.com",
    password: "password123"
  }

  @update_attrs %{
    email: "updated@example.com"
  }

  @invalid_attrs %{email: "invalid"}

  setup %{conn: conn} do
    {:ok, user, access_token, _refresh_token} = Authentication.register(@create_attrs)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{access_token}")

    {:ok, conn: conn, user: user, token: access_token}
  end

  describe "show" do
    test "returns current user profile", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/user/profile")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == user.id
      assert data["email"] == user.email
    end

    test "returns unauthorized without token", %{conn: conn} do
      conn =
        conn
        |> delete_req_header("authorization")
        |> get(~p"/api/user/profile")

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "returns unauthorized with invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer invalid.token.here")
        |> get(~p"/api/user/profile")

      assert json_response(conn, 401)
    end
  end

  describe "update" do
    test "updates when data is valid", %{conn: conn} do
      conn = put(conn, ~p"/api/user/profile", @update_attrs)
      assert %{"data" => data} = json_response(conn, 200)
      assert data["email"] == "updated@example.com"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = put(conn, ~p"/api/user/profile", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns unauthorized without token", %{conn: conn} do
      conn =
        conn
        |> delete_req_header("authorization")
        |> put(~p"/api/user/profile", @update_attrs)

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end

  describe "delete" do
    test "deletes user account", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/user/profile")
      assert response(conn, 204)

      # Verify user is deleted
      assert Authentication.get_user(user.id) == nil
    end

    test "returns unauthorized without token", %{conn: conn} do
      conn =
        conn
        |> delete_req_header("authorization")
        |> delete(~p"/api/user/profile")

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
