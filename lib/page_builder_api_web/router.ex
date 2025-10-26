defmodule PageBuilderApiWeb.Router do
  use PageBuilderApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug PageBuilderApiWeb.Plugs.AuthPipeline
  end

  pipeline :registration_rate_limit do
    plug PageBuilderApiWeb.Plugs.RateLimit, max_requests: 5, interval_ms: 3_600_000
  end

  pipeline :login_rate_limit do
    plug PageBuilderApiWeb.Plugs.RateLimit, max_requests: 20, interval_ms: 3_600_000
  end

  scope "/api", PageBuilderApiWeb do
    pipe_through :api

    get "/health", HealthCheckController, :run
  end

  scope "/api", PageBuilderApiWeb do
    pipe_through [:api, :registration_rate_limit]

    # Public authentication routes with rate limiting
    post "/auth/register", AuthController, :register
  end

  scope "/api", PageBuilderApiWeb do
    pipe_through [:api, :login_rate_limit]

    post "/auth/login", AuthController, :login
  end

  scope "/api", PageBuilderApiWeb do
    pipe_through [:api, :auth]

    # User profile routes
    get "/user/profile", UserController, :show
    put "/user/profile", UserController, :update
    delete "/user/profile", UserController, :delete
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:page_builder_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PageBuilderApiWeb.Telemetry
    end
  end
end
