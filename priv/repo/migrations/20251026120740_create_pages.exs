defmodule PageBuilderApi.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :label, :string, null: false, size: 50
      add :description, :string, size: 250

      timestamps(type: :utc_datetime)
    end
  end
end
