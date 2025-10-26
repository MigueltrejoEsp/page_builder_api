defmodule PageBuilderApiWeb.UserLinkJSON do
  alias PageBuilderApi.Pages.UserLink

  @doc """
  Renders a list of user_links.
  """
  def index(%{user_links: user_links}) do
    %{data: for(user_link <- user_links, do: data(user_link))}
  end

  @doc """
  Renders a single user_link.
  """
  def show(%{user_link: user_link}) do
    %{data: data(user_link)}
  end

  defp data(%UserLink{} = user_link) do
    %{
      id: user_link.id,
      label: user_link.label,
      url: user_link.url
    }
  end
end
