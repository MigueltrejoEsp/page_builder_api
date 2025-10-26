defmodule PageBuilderApiWeb.PageControllerTest do
  use PageBuilderApiWeb.ConnCase

  import PageBuilderApi.PagesFixtures

  alias PageBuilderApi.Pages.Page

  @create_attrs %{
    label: "some label",
    description: "some description"
  }
  @update_attrs %{
    label: "some updated label",
    description: "some updated description"
  }
  @invalid_attrs %{label: nil, description: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all pages", %{conn: conn} do
      conn = get(conn, ~p"/api/pages")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create page" do
    test "renders page when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/pages", page: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/pages/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "label" => "some label"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/pages", page: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update page" do
    setup [:create_page]

    test "renders page when data is valid", %{conn: conn, page: %Page{id: id} = page} do
      conn = put(conn, ~p"/api/pages/#{page}", page: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/pages/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "label" => "some updated label"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, page: page} do
      conn = put(conn, ~p"/api/pages/#{page}", page: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete page" do
    setup [:create_page]

    test "deletes chosen page", %{conn: conn, page: page} do
      conn = delete(conn, ~p"/api/pages/#{page}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/pages/#{page}")
      end
    end
  end

  defp create_page(_) do
    page = page_fixture()
    %{page: page}
  end
end
