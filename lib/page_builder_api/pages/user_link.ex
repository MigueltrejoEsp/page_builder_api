defmodule PageBuilderApi.Pages.UserLink do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_links" do
    field :label, :string
    field :url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_link, attrs) do
    user_link
    |> cast(attrs, [:label, :url])
    |> validate_required([:label, :url])
  end
end
