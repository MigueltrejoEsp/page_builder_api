# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :page_builder_api,
  ecto_repos: [PageBuilderApi.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :page_builder_api, PageBuilderApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: PageBuilderApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PageBuilderApi.PubSub,
  live_view: [signing_salt: "8CBdINnr"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian configuration
config :page_builder_api, PageBuilderApi.Guardian,
  issuer: "page_builder_api",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

# Hammer rate limiting configuration
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
