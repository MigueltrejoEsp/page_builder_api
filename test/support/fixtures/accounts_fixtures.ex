defmodule PageBuilderApi.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PageBuilderApi.Accounts` context.
  """

  @doc """
  Generate a user_link.
  """
  def user_link_fixture(attrs \\ %{}) do
    {:ok, user_link} =
      attrs
      |> Enum.into(%{
        label: "some label",
        url: "some url"
      })
      |> PageBuilderApi.Accounts.create_user_link()

    user_link
  end
end
