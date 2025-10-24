defmodule PageBuilderApi.AccountsTest do
  use PageBuilderApi.DataCase

  alias PageBuilderApi.Accounts

  describe "user_links" do
    alias PageBuilderApi.Accounts.UserLink

    import PageBuilderApi.AccountsFixtures

    @invalid_attrs %{label: nil, url: nil}

    test "list_user_links/0 returns all user_links" do
      user_link = user_link_fixture()
      assert Accounts.list_user_links() == [user_link]
    end

    test "get_user_link!/1 returns the user_link with given id" do
      user_link = user_link_fixture()
      assert Accounts.get_user_link!(user_link.id) == user_link
    end

    test "create_user_link/1 with valid data creates a user_link" do
      valid_attrs = %{label: "some label", url: "some url"}

      assert {:ok, %UserLink{} = user_link} = Accounts.create_user_link(valid_attrs)
      assert user_link.label == "some label"
      assert user_link.url == "some url"
    end

    test "create_user_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_link(@invalid_attrs)
    end

    test "update_user_link/2 with valid data updates the user_link" do
      user_link = user_link_fixture()
      update_attrs = %{label: "some updated label", url: "some updated url"}

      assert {:ok, %UserLink{} = user_link} = Accounts.update_user_link(user_link, update_attrs)
      assert user_link.label == "some updated label"
      assert user_link.url == "some updated url"
    end

    test "update_user_link/2 with invalid data returns error changeset" do
      user_link = user_link_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_link(user_link, @invalid_attrs)
      assert user_link == Accounts.get_user_link!(user_link.id)
    end

    test "delete_user_link/1 deletes the user_link" do
      user_link = user_link_fixture()
      assert {:ok, %UserLink{}} = Accounts.delete_user_link(user_link)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_link!(user_link.id) end
    end

    test "change_user_link/1 returns a user_link changeset" do
      user_link = user_link_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_link(user_link)
    end
  end
end
