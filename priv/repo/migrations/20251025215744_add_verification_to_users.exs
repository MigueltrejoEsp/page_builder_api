defmodule PageBuilderApi.Repo.Migrations.AddVerificationToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :verified, :boolean, default: false, null: false
      add :verification_token, :string
      add :verification_sent_at, :utc_datetime
    end

    create index(:users, [:verification_token])
  end
end
