defmodule PageBuilderApiWeb.AuthJSON do
  alias PageBuilderApi.Auth.User

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
  Renders logout success message.
  """
  def logout(%{message: message}) do
    %{message: message}
  end

  @doc """
  Renders logout all success message.
  """
  def logout_all(%{message: message}) do
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
