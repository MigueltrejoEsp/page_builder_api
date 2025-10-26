defmodule PageBuilderApiWeb.AuthControllerTest do
  use PageBuilderApiWeb.ConnCase

  import Ecto.Query

  alias PageBuilderApi.Auth

  @create_attrs %{
    email: "test@example.com",
    password: "password123"
  }

  @invalid_attrs %{email: "invalid", password: "short"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register" do
    test "renders user and tokens when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", @create_attrs)
      assert %{"data" => data} = json_response(conn, 201)

      assert %{"user" => user, "access_token" => access_token, "refresh_token" => refresh_token} =
               data

      assert user["email"] == "test@example.com"
      assert is_binary(access_token)
      assert String.length(access_token) > 0
      assert is_binary(refresh_token)
      assert String.length(refresh_token) > 0
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

    @tag :rate_limiting
    test "enforces rate limit of 5 requests per hour", %{conn: conn} do
      # Temporarily enable rate limiting for this test
      original_value = Application.get_env(:page_builder_api, :enable_rate_limiting)
      Application.put_env(:page_builder_api, :enable_rate_limiting, true)

      try do
        # Make 5 requests
        for i <- 1..5 do
          post(conn, ~p"/api/auth/register", %{
            email: "user#{i}@test.com",
            password: "password123"
          })
        end

        # 6th request should be rate limited
        conn =
          post(conn, ~p"/api/auth/register", %{
            email: "user6@test.com",
            password: "password123"
          })

        assert conn.status == 429
        assert json_response(conn, 429)["error"] =~ "Too many requests"
      after
        # Restore original value
        Application.put_env(:page_builder_api, :enable_rate_limiting, original_value)
      end
    end
  end

  describe "login" do
    setup [:create_user]

    test "renders user and tokens when credentials are valid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/auth/login", %{email: "test@example.com", password: "password123"})

      assert %{"data" => data} = json_response(conn, 200)

      assert %{"user" => user, "access_token" => access_token, "refresh_token" => refresh_token} =
               data

      assert user["email"] == "test@example.com"
      assert is_binary(access_token)
      assert is_binary(refresh_token)
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

    @tag :rate_limiting
    test "enforces rate limit of 20 requests per hour", %{conn: conn} do
      # Temporarily enable rate limiting for this test
      original_value = Application.get_env(:page_builder_api, :enable_rate_limiting)
      Application.put_env(:page_builder_api, :enable_rate_limiting, true)

      try do
        # Make 20 requests (all will fail auth but that's ok)
        for _i <- 1..20 do
          post(conn, ~p"/api/auth/login", %{
            email: "test@example.com",
            password: "wrongpassword"
          })
        end

        # 21st request should be rate limited
        conn =
          post(conn, ~p"/api/auth/login", %{
            email: "test@example.com",
            password: "wrongpassword"
          })

        assert conn.status == 429
        assert json_response(conn, 429)["error"] =~ "Too many requests"
      after
        # Restore original value
        Application.put_env(:page_builder_api, :enable_rate_limiting, original_value)
      end
    end
  end

  describe "refresh" do
    setup [:create_user]

    test "returns new token pair with valid refresh token", %{
      conn: conn,
      refresh_token: refresh_token
    } do
      conn = post(conn, ~p"/api/auth/refresh", %{refresh_token: refresh_token})

      assert %{"data" => data} = json_response(conn, 200)
      assert %{"access_token" => new_access_token, "refresh_token" => new_refresh_token} = data
      assert is_binary(new_access_token)
      assert is_binary(new_refresh_token)
      assert new_refresh_token != refresh_token
    end

    test "renders error with invalid refresh token", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/refresh", %{refresh_token: "invalid_token"})

      assert json_response(conn, 401)["error"] == "Invalid refresh token"
    end

    test "renders error with revoked refresh token", %{conn: conn, refresh_token: refresh_token} do
      # Revoke the token first
      post(conn, ~p"/api/auth/logout", %{refresh_token: refresh_token})

      # Try to use the revoked token
      conn = post(conn, ~p"/api/auth/refresh", %{refresh_token: refresh_token})

      assert json_response(conn, 401)["error"] == "Refresh token has been revoked"
    end

    test "renders error when refresh_token is missing", %{conn: conn} do
      assert_error_sent 400, fn ->
        post(conn, ~p"/api/auth/refresh", %{})
      end
    end
  end

  describe "logout" do
    setup [:create_user]

    test "successfully logs out with valid refresh token", %{
      conn: conn,
      refresh_token: refresh_token
    } do
      conn = post(conn, ~p"/api/auth/logout", %{refresh_token: refresh_token})

      assert %{"message" => message} = json_response(conn, 200)
      assert message == "Successfully logged out"

      # Verify token cannot be used again
      conn = post(conn, ~p"/api/auth/refresh", %{refresh_token: refresh_token})
      assert json_response(conn, 401)["error"] == "Refresh token has been revoked"
    end

    test "renders error with invalid refresh token", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/logout", %{refresh_token: "invalid_token"})

      assert json_response(conn, 404)["error"] == "Invalid refresh token"
    end

    test "renders error when refresh_token is missing", %{conn: conn} do
      assert_error_sent 400, fn ->
        post(conn, ~p"/api/auth/logout", %{})
      end
    end
  end

  describe "logout_all" do
    setup [:create_user]

    test "logs out from all devices", %{
      conn: conn,
      access_token: access_token,
      refresh_token: refresh_token
    } do
      # Create another session
      login_conn =
        post(conn, ~p"/api/auth/login", %{email: "test@example.com", password: "password123"})

      %{"data" => %{"refresh_token" => refresh_token2}} = json_response(login_conn, 200)

      # Logout all
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")
        |> post(~p"/api/auth/logout-all")

      assert %{"message" => message} = json_response(conn, 200)
      assert message =~ "Logged out from"
      assert message =~ "device(s)"

      # Verify both tokens are revoked
      conn1 = post(conn, ~p"/api/auth/refresh", %{refresh_token: refresh_token})
      assert json_response(conn1, 401)["error"] == "Refresh token has been revoked"

      conn2 = post(conn, ~p"/api/auth/refresh", %{refresh_token: refresh_token2})
      assert json_response(conn2, 401)["error"] == "Refresh token has been revoked"
    end

    test "requires authentication", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/logout-all")
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "returns count of 0 when no active sessions", %{
      conn: conn,
      access_token: access_token,
      refresh_token: refresh_token
    } do
      # Logout first
      post(conn, ~p"/api/auth/logout", %{refresh_token: refresh_token})

      # Try logout all
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")
        |> post(~p"/api/auth/logout-all")

      assert %{"message" => message} = json_response(conn, 200)
      assert message == "Logged out from 0 device(s)"
    end
  end

  describe "unregister" do
    setup [:create_user]

    test "deletes user account when authenticated", %{
      conn: conn,
      access_token: access_token,
      user: user
    } do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")
        |> delete(~p"/api/auth/unregister")

      assert response(conn, 204)

      # Verify user is deleted
      assert Auth.get_user(user.id) == nil
    end

    test "requires authentication", %{conn: conn} do
      conn = delete(conn, ~p"/api/auth/unregister")
      assert json_response(conn, 401)["error"] == "unauthenticated"
    end

    test "deletes all associated refresh tokens", %{
      conn: conn,
      access_token: access_token,
      user: user
    } do
      # Create another session
      post(conn, ~p"/api/auth/login", %{email: "test@example.com", password: "password123"})

      # Count refresh tokens before deletion
      refresh_tokens_before =
        PageBuilderApi.Repo.all(
          from rt in PageBuilderApi.Auth.RefreshToken,
            where: rt.user_id == ^user.id
        )

      assert length(refresh_tokens_before) == 2

      # Delete account
      conn
      |> put_req_header("authorization", "Bearer #{access_token}")
      |> delete(~p"/api/auth/unregister")

      # Verify refresh tokens are deleted (cascade delete)
      refresh_tokens_after =
        PageBuilderApi.Repo.all(
          from rt in PageBuilderApi.Auth.RefreshToken,
            where: rt.user_id == ^user.id
        )

      assert length(refresh_tokens_after) == 0
    end
  end

  defp create_user(_) do
    {:ok, user, access_token, refresh_token} = Auth.register(@create_attrs)
    %{user: user, access_token: access_token, refresh_token: refresh_token}
  end
end
