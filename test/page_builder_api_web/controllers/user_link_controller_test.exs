defmodule PageBuilderApiWeb.UserLinkControllerTest do
  use PageBuilderApiWeb.ConnCase

  import PageBuilderApi.PagesFixtures

  alias PageBuilderApi.Pages.UserLink

  @create_attrs %{
    label: "some label",
    url: "some url"
  }
  @update_attrs %{
    label: "some updated label",
    url: "some updated url"
  }
  @invalid_attrs %{label: nil, url: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all user_links", %{conn: conn} do
      conn = get(conn, ~p"/api/user_links")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_link" do
    test "renders user_link when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/user_links", user_link: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/user_links/#{id}")

      assert %{
               "id" => ^id,
               "label" => "some label",
               "url" => "some url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/user_links", user_link: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_link" do
    setup [:create_user_link]

    test "renders user_link when data is valid", %{conn: conn, user_link: %UserLink{id: id} = user_link} do
      conn = put(conn, ~p"/api/user_links/#{user_link}", user_link: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/user_links/#{id}")

      assert %{
               "id" => ^id,
               "label" => "some updated label",
               "url" => "some updated url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user_link: user_link} do
      conn = put(conn, ~p"/api/user_links/#{user_link}", user_link: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_link" do
    setup [:create_user_link]

    test "deletes chosen user_link", %{conn: conn, user_link: user_link} do
      conn = delete(conn, ~p"/api/user_links/#{user_link}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/user_links/#{user_link}")
      end
    end
  end

  defp create_user_link(_) do
    user_link = user_link_fixture()
    %{user_link: user_link}
  end
end
