defmodule PageBuilderApi.Pages.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :label, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:label, :description])
    |> validate_required([:label])
    |> validate_length(:label, max: 50)
    |> validate_length(:description, max: 250)
  end
end
