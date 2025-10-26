defmodule PageBuilderApiWeb.PageJSON do
  alias PageBuilderApi.Pages.Page

  @doc """
  Renders a list of pages.
  """
  def index(%{pages: pages}) do
    %{data: for(page <- pages, do: data(page))}
  end

  @doc """
  Renders a single page.
  """
  def show(%{page: page}) do
    %{data: data(page)}
  end

  defp data(%Page{} = page) do
    %{
      id: page.id,
      label: page.label,
      description: page.description
    }
  end
end
