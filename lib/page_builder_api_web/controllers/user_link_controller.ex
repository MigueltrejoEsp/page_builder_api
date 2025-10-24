defmodule PageBuilderApiWeb.UserLinkController do
  use PageBuilderApiWeb, :controller

  alias PageBuilderApi.Accounts
  alias PageBuilderApi.Accounts.UserLink

  action_fallback PageBuilderApiWeb.FallbackController

  def index(conn, _params) do
    user_links = Accounts.list_user_links()
    render(conn, :index, user_links: user_links)
  end

  def create(conn, %{"user_link" => user_link_params}) do
    with {:ok, %UserLink{} = user_link} <- Accounts.create_user_link(user_link_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/user_links/#{user_link}")
      |> render(:show, user_link: user_link)
    end
  end

  def show(conn, %{"id" => id}) do
    user_link = Accounts.get_user_link!(id)
    render(conn, :show, user_link: user_link)
  end

  def update(conn, %{"id" => id, "user_link" => user_link_params}) do
    user_link = Accounts.get_user_link!(id)

    with {:ok, %UserLink{} = user_link} <- Accounts.update_user_link(user_link, user_link_params) do
      render(conn, :show, user_link: user_link)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_link = Accounts.get_user_link!(id)

    with {:ok, %UserLink{}} <- Accounts.delete_user_link(user_link) do
      send_resp(conn, :no_content, "")
    end
  end
end
