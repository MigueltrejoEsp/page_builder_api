defmodule PageBuilderApi.Repo do
  use Ecto.Repo,
    otp_app: :page_builder_api,
    adapter: Ecto.Adapters.Postgres
end
