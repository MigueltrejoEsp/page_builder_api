defmodule PageBuilderApiWeb.UserController do
  use PageBuilderApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias PageBuilderApi.Authentication
  alias PageBuilderApi.Guardian

  alias PageBuilderApiWeb.Schemas.{
    UserResponse,
    UserUpdate,
    ErrorResponse,
    ValidationErrorResponse
  }

  action_fallback PageBuilderApiWeb.FallbackController

  tags(["User Profile"])

  operation(:show,
    summary: "Get current user profile",
    description: "Retrieve the authenticated user's profile information",
    security: [%{"bearer" => []}],
    responses: [
      ok: {"User profile", "application/json", UserResponse},
      unauthorized: {"Not authenticated", "application/json", ErrorResponse}
    ]
  )

  @doc """
  Get current user profile
  """
  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, :user, user: user)
  end

  operation(:update,
    summary: "Update user profile",
    description: "Update the authenticated user's profile information",
    security: [%{"bearer" => []}],
    request_body: {"User updates", "application/json", UserUpdate, required: true},
    responses: [
      ok: {"Updated user profile", "application/json", UserResponse},
      unauthorized: {"Not authenticated", "application/json", ErrorResponse},
      unprocessable_entity: {
        "Validation error",
        "application/json",
        ValidationErrorResponse
      }
    ]
  )

  @doc """
  Update current user profile
  """
  def update(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, updated_user} <- Authentication.update_user(user, params) do
      render(conn, :user, user: updated_user)
    end
  end

  operation(:delete,
    summary: "Delete user account",
    description: "Permanently delete the authenticated user's account and all associated data",
    security: [%{"bearer" => []}],
    responses: [
      no_content: {"Account deleted successfully", "application/json", nil},
      unauthorized: {"Not authenticated", "application/json", ErrorResponse}
    ]
  )

  @doc """
  Delete current user account
  """
  def delete(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _user} <- Authentication.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
