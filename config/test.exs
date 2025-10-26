import Config

# Set environment to test
config :page_builder_api, :env, :test

# Disable rate limiting in tests
config :page_builder_api, :enable_rate_limiting, false

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :page_builder_api, PageBuilderApi.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "page_builder_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :page_builder_api, PageBuilderApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "OcfYzyahdYbKle6wj4ALIXhD47QMqYubBZDbdvnhiGRVoV46SDzJ+hqhDTck3oMK",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
