defmodule PageBuilderApiWeb.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Paths, Server, Components, SecurityScheme}
  alias PageBuilderApiWeb.{Endpoint, Router}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "Page Builder API",
        version: "1.0.0",
        description: """
        REST API for the Page Builder web application.

        ## Authentication

        This API uses JWT-based authentication with a dual-token pattern:
        - **Access Tokens**: Short-lived (1 hour), use in Authorization header
        - **Refresh Tokens**: Long-lived (30 days), use to get new access tokens

        ## Getting Started

        1. Register or login to get tokens
        2. Use access token in `Authorization: Bearer {token}` header
        3. Refresh access token when it expires
        4. Logout to revoke refresh token
        """
      },
      paths: Paths.from_router(Router),
      components: %Components{
        securitySchemes: %{
          "bearer" => %SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT",
            description: "JWT access token (1 hour expiration)"
          }
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
