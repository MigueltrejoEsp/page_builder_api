defmodule PageBuilderApiWeb.AuthController do
  use PageBuilderApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias PageBuilderApi.Authentication

  alias PageBuilderApiWeb.Schemas.{
    UserCredentials,
    AuthResponse,
    RefreshTokenRequest,
    RefreshResponse,
    MessageResponse,
    ErrorResponse,
    ValidationErrorResponse
  }

  action_fallback PageBuilderApiWeb.FallbackController

  tags(["Authentication"])

  operation(:register,
    summary: "Register a new user",
    description: "Create a new user account and receive authentication tokens",
    request_body: {"User credentials", "application/json", UserCredentials, required: true},
    responses: [
      created: {"Success - User registered", "application/json", AuthResponse},
      unprocessable_entity: {
        "Validation error",
        "application/json",
        ValidationErrorResponse
      },
      too_many_requests: {"Rate limit exceeded (5 per hour)", "application/json", ErrorResponse}
    ]
  )

  @doc """
  Register a new user
  """
  def register(conn, %{"email" => email, "password" => password}) do
    case Authentication.register(%{email: email, password: password}) do
      {:ok, user, access_token, refresh_token} ->
        conn
        |> put_status(:created)
        |> render(:tokens, user: user, access_token: access_token, refresh_token: refresh_token)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: PageBuilderApiWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  operation(:login,
    summary: "Login user",
    description: "Authenticate user and receive authentication tokens",
    request_body: {"User credentials", "application/json", UserCredentials, required: true},
    responses: [
      ok: {"Success - User logged in", "application/json", AuthResponse},
      unauthorized: {"Invalid credentials", "application/json", ErrorResponse},
      too_many_requests: {"Rate limit exceeded (20 per hour)", "application/json", ErrorResponse}
    ]
  )

  @doc """
  Login a user
  """
  def login(conn, %{"email" => email, "password" => password}) do
    case Authentication.login(email, password) do
      {:ok, user, access_token, refresh_token} ->
        render(conn, :tokens,
          user: user,
          access_token: access_token,
          refresh_token: refresh_token
        )

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, message: "Invalid email or password")
    end
  end

  operation(:refresh,
    summary: "Refresh access token",
    description:
      "Get a new access and refresh token pair using a valid refresh token. The old refresh token is automatically revoked.",
    request_body: {"Refresh token", "application/json", RefreshTokenRequest, required: true},
    responses: [
      ok: {"Success - New tokens issued", "application/json", RefreshResponse},
      unauthorized:
        {"Invalid, expired, or revoked refresh token", "application/json", ErrorResponse}
    ]
  )

  @doc """
  Refresh access token using refresh token
  """
  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Authentication.refresh(refresh_token) do
      {:ok, access_token, new_refresh_token} ->
        render(conn, :refresh, access_token: access_token, refresh_token: new_refresh_token)

      {:error, :invalid_token} ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, message: "Invalid refresh token")

      {:error, :token_expired} ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, message: "Refresh token expired")

      {:error, :token_revoked} ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, message: "Refresh token has been revoked")

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, message: "Unable to refresh token")
    end
  end

  operation(:logout,
    summary: "Logout user (single device)",
    description:
      "Revoke the refresh token to logout from the current device. The access token remains valid until expiration (max 1 hour).",
    request_body:
      {"Refresh token to revoke", "application/json", RefreshTokenRequest, required: true},
    responses: [
      ok: {"Successfully logged out", "application/json", MessageResponse},
      not_found: {"Invalid or already revoked refresh token", "application/json", ErrorResponse}
    ]
  )

  @doc """
  Logout user by revoking refresh token
  """
  def logout(conn, %{"refresh_token" => refresh_token}) do
    case Authentication.logout(refresh_token) do
      {:ok, :logged_out} ->
        render(conn, :message, message: "Successfully logged out")

      {:error, :invalid_token} ->
        conn
        |> put_status(:not_found)
        |> render(:error, message: "Invalid refresh token")
    end
  end

  operation(:logout_all,
    summary: "Logout from all devices",
    description:
      "Revoke all refresh tokens for the authenticated user. This logs the user out from all devices.",
    security: [%{"bearer" => []}],
    responses: [
      ok: {"Success - Logged out from all devices", "application/json", MessageResponse},
      unauthorized: {"Not authenticated", "application/json", ErrorResponse}
    ]
  )

  @doc """
  Logout user from all devices
  """
  def logout_all(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    case Authentication.logout_all(user) do
      {:ok, count} ->
        render(conn, :message, message: "Logged out from #{count} device(s)")
    end
  end
end
