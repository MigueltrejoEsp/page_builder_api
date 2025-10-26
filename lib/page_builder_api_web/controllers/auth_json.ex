defmodule PageBuilderApiWeb.AuthJSON do
  alias PageBuilderApi.Authentication.User

  @doc """
  Renders tokens with user data (for register and login).
  """
  def tokens(%{user: user, access_token: access_token, refresh_token: refresh_token}) do
    %{
      data: %{
        user: user_data(user),
        access_token: access_token,
        refresh_token: refresh_token
      }
    }
  end

  @doc """
  Renders new token pair (for refresh).
  """
  def refresh(%{access_token: access_token, refresh_token: refresh_token}) do
    %{
      data: %{
        access_token: access_token,
        refresh_token: refresh_token
      }
    }
  end

  @doc """
  Renders a single user.
  """
  def user(%{user: user}) do
    %{data: user_data(user)}
  end

  @doc """
  Renders a message.
  """
  def message(%{message: message}) do
    %{message: message}
  end

  @doc """
  Renders an error message.
  """
  def error(%{message: message}) do
    %{error: message}
  end

  defp user_data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
