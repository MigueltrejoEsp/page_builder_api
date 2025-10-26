defmodule PageBuilderApi.Pages do
  @moduledoc """
  The Pages context.
  """

  import Ecto.Query, warn: false
  alias PageBuilderApi.Repo

  alias PageBuilderApi.Pages.Page

  @doc """
  Returns the list of pages.

  ## Examples

      iex> list_pages()
      [%Page{}, ...]

  """
  def list_pages do
    Repo.all(Page)
  end

  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page!(id), do: Repo.get!(Page, id)

  @doc """
  Creates a page.

  ## Examples

      iex> create_page(%{field: value})
      {:ok, %Page{}}

      iex> create_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page(attrs \\ %{}) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a page.

  ## Examples

      iex> update_page(page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a page.

  ## Examples

      iex> delete_page(page)
      {:ok, %Page{}}

      iex> delete_page(page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page changes.

  ## Examples

      iex> change_page(page)
      %Ecto.Changeset{data: %Page{}}

  """
  def change_page(%Page{} = page, attrs \\ %{}) do
    Page.changeset(page, attrs)
  end

  alias PageBuilderApi.Pages.UserLink

  @doc """
  Returns the list of user_links.

  ## Examples

      iex> list_user_links()
      [%UserLink{}, ...]

  """
  def list_user_links do
    Repo.all(UserLink)
  end

  @doc """
  Gets a single user_link.

  Raises `Ecto.NoResultsError` if the User link does not exist.

  ## Examples

      iex> get_user_link!(123)
      %UserLink{}

      iex> get_user_link!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_link!(id), do: Repo.get!(UserLink, id)

  @doc """
  Creates a user_link.

  ## Examples

      iex> create_user_link(%{field: value})
      {:ok, %UserLink{}}

      iex> create_user_link(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_link(attrs \\ %{}) do
    %UserLink{}
    |> UserLink.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_link.

  ## Examples

      iex> update_user_link(user_link, %{field: new_value})
      {:ok, %UserLink{}}

      iex> update_user_link(user_link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_link(%UserLink{} = user_link, attrs) do
    user_link
    |> UserLink.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_link.

  ## Examples

      iex> delete_user_link(user_link)
      {:ok, %UserLink{}}

      iex> delete_user_link(user_link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_link(%UserLink{} = user_link) do
    Repo.delete(user_link)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_link changes.

  ## Examples

      iex> change_user_link(user_link)
      %Ecto.Changeset{data: %UserLink{}}

  """
  def change_user_link(%UserLink{} = user_link, attrs \\ %{}) do
    UserLink.changeset(user_link, attrs)
  end
end
