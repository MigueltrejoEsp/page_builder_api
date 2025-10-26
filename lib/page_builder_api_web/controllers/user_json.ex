defmodule PageBuilderApiWeb.UserJSON do
  alias PageBuilderApi.Authentication.User

  @doc """
  Renders a single user.
  """
  def user(%{user: user}) do
    %{data: user_data(user)}
  end

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: user_data(user))}
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
