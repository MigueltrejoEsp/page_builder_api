defmodule PageBuilderApiWeb.UserController do
  use PageBuilderApiWeb, :controller

  alias PageBuilderApi.Authentication
  alias PageBuilderApi.Guardian

  action_fallback PageBuilderApiWeb.FallbackController

  @doc """
  Get current user profile
  """
  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, :user, user: user)
  end

  @doc """
  Update current user profile
  """
  def update(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, updated_user} <- Authentication.update_user(user, params) do
      render(conn, :user, user: updated_user)
    end
  end

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
