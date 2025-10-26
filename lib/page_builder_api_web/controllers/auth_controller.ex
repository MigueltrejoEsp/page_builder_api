defmodule PageBuilderApiWeb.AuthController do
  use PageBuilderApiWeb, :controller

  alias PageBuilderApi.Authentication

  action_fallback PageBuilderApiWeb.FallbackController

  @doc """
  Register a new user
  """
  def register(conn, %{"email" => email, "password" => password}) do
    case Authentication.register(%{email: email, password: password}) do
      {:ok, user, token} ->
        conn
        |> put_status(:created)
        |> render(:user_with_token, user: user, token: token)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: PageBuilderApiWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  @doc """
  Login a user
  """
  def login(conn, %{"email" => email, "password" => password}) do
    case Authentication.login(email, password) do
      {:ok, user, token} ->
        render(conn, :user_with_token, user: user, token: token)

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, message: "Invalid email or password")
    end
  end
end
