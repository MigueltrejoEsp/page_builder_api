defmodule PageBuilderApi.PagesTest do
  use PageBuilderApi.DataCase

  alias PageBuilderApi.Pages

  describe "pages" do
    alias PageBuilderApi.Pages.Page

    import PageBuilderApi.PagesFixtures

    @invalid_attrs %{label: nil, description: nil}

    test "list_pages/0 returns all pages" do
      page = page_fixture()
      assert Pages.list_pages() == [page]
    end

    test "get_page!/1 returns the page with given id" do
      page = page_fixture()
      assert Pages.get_page!(page.id) == page
    end

    test "create_page/1 with valid data creates a page" do
      valid_attrs = %{label: "some label", description: "some description"}

      assert {:ok, %Page{} = page} = Pages.create_page(valid_attrs)
      assert page.label == "some label"
      assert page.description == "some description"
    end

    test "create_page/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pages.create_page(@invalid_attrs)
    end

    test "update_page/2 with valid data updates the page" do
      page = page_fixture()
      update_attrs = %{label: "some updated label", description: "some updated description"}

      assert {:ok, %Page{} = page} = Pages.update_page(page, update_attrs)
      assert page.label == "some updated label"
      assert page.description == "some updated description"
    end

    test "update_page/2 with invalid data returns error changeset" do
      page = page_fixture()
      assert {:error, %Ecto.Changeset{}} = Pages.update_page(page, @invalid_attrs)
      assert page == Pages.get_page!(page.id)
    end

    test "delete_page/1 deletes the page" do
      page = page_fixture()
      assert {:ok, %Page{}} = Pages.delete_page(page)
      assert_raise Ecto.NoResultsError, fn -> Pages.get_page!(page.id) end
    end

    test "change_page/1 returns a page changeset" do
      page = page_fixture()
      assert %Ecto.Changeset{} = Pages.change_page(page)
    end
  end

  describe "user_links" do
    alias PageBuilderApi.Pages.UserLink

    import PageBuilderApi.PagesFixtures

    @invalid_attrs %{label: nil, url: nil}

    test "list_user_links/0 returns all user_links" do
      user_link = user_link_fixture()
      assert Pages.list_user_links() == [user_link]
    end

    test "get_user_link!/1 returns the user_link with given id" do
      user_link = user_link_fixture()
      assert Pages.get_user_link!(user_link.id) == user_link
    end

    test "create_user_link/1 with valid data creates a user_link" do
      valid_attrs = %{label: "some label", url: "some url"}

      assert {:ok, %UserLink{} = user_link} = Pages.create_user_link(valid_attrs)
      assert user_link.label == "some label"
      assert user_link.url == "some url"
    end

    test "create_user_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pages.create_user_link(@invalid_attrs)
    end

    test "update_user_link/2 with valid data updates the user_link" do
      user_link = user_link_fixture()
      update_attrs = %{label: "some updated label", url: "some updated url"}

      assert {:ok, %UserLink{} = user_link} = Pages.update_user_link(user_link, update_attrs)
      assert user_link.label == "some updated label"
      assert user_link.url == "some updated url"
    end

    test "update_user_link/2 with invalid data returns error changeset" do
      user_link = user_link_fixture()
      assert {:error, %Ecto.Changeset{}} = Pages.update_user_link(user_link, @invalid_attrs)
      assert user_link == Pages.get_user_link!(user_link.id)
    end

    test "delete_user_link/1 deletes the user_link" do
      user_link = user_link_fixture()
      assert {:ok, %UserLink{}} = Pages.delete_user_link(user_link)
      assert_raise Ecto.NoResultsError, fn -> Pages.get_user_link!(user_link.id) end
    end

    test "change_user_link/1 returns a user_link changeset" do
      user_link = user_link_fixture()
      assert %Ecto.Changeset{} = Pages.change_user_link(user_link)
    end
  end
end
