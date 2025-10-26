defmodule PageBuilderApiWeb.Plugs.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :page_builder_api,
    module: PageBuilderApi.Guardian,
    error_handler: PageBuilderApiWeb.Plugs.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
