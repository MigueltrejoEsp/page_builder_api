defmodule PageBuilderApi.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :label, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
