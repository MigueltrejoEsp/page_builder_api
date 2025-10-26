defmodule PageBuilderApiWeb.AuthJSON do
  alias PageBuilderApi.Authentication.User

  @doc """
  Renders a user with token.
  """
  def user_with_token(%{user: user, token: token}) do
    %{
      data: %{
        user: user_data(user),
        token: token
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
