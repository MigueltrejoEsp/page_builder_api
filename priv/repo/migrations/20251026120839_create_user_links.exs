defmodule PageBuilderApi.Repo.Migrations.CreateUserLinks do
  use Ecto.Migration

  def change do
    create table(:user_links) do
      add :label, :string, null: false
      add :url, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
