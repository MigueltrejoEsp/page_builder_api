defmodule PageBuilderApi.PagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PageBuilderApi.Pages` context.
  """

  @doc """
  Generate a page.
  """
  def page_fixture(attrs \\ %{}) do
    {:ok, page} =
      attrs
      |> Enum.into(%{
        description: "some description",
        label: "some label"
      })
      |> PageBuilderApi.Pages.create_page()

    page
  end

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
      |> PageBuilderApi.Pages.create_user_link()

    user_link
  end
end
