defmodule PageBuilderApiWeb.Schemas do
  alias OpenApiSpex.Schema

  defmodule User do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "User",
      description: "A user account",
      type: :object,
      properties: %{
        id: %Schema{type: :string, format: :uuid, description: "User ID"},
        email: %Schema{type: :string, format: :email, description: "User email address"},
        inserted_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Account creation timestamp"
        },
        updated_at: %Schema{
          type: :string,
          format: :"date-time",
          description: "Last update timestamp"
        }
      },
      required: [:id, :email],
      example: %{
        "id" => "a8b9c0d1-e2f3-4g5h-6i7j-8k9l0m1n2o3p",
        "email" => "user@example.com",
        "inserted_at" => "2025-10-25T12:00:00Z",
        "updated_at" => "2025-10-25T12:00:00Z"
      }
    })
  end

  defmodule UserCredentials do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "UserCredentials",
      description: "User login/registration credentials",
      type: :object,
      properties: %{
        email: %Schema{
          type: :string,
          format: :email,
          description: "User email address",
          minLength: 1,
          maxLength: 160
        },
        password: %Schema{
          type: :string,
          description: "User password",
          minLength: 8,
          maxLength: 80,
          format: :password
        }
      },
      required: [:email, :password],
      example: %{
        "email" => "user@example.com",
        "password" => "password123"
      }
    })
  end

  defmodule TokenPair do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "TokenPair",
      description: "Access and refresh token pair",
      type: :object,
      properties: %{
        access_token: %Schema{type: :string, description: "JWT access token (1 hour expiration)"},
        refresh_token: %Schema{
          type: :string,
          description: "Refresh token (30 days expiration, database-backed)"
        }
      },
      required: [:access_token, :refresh_token],
      example: %{
        "access_token" => "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9...",
        "refresh_token" => "gq9tNOJ8N6L7x4h2vb5ocavAo6BRLBHoQR6FDWvqZT4"
      }
    })
  end

  defmodule AuthResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "AuthResponse",
      description: "Authentication response with user and tokens",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            user: User,
            access_token: %Schema{type: :string, description: "JWT access token"},
            refresh_token: %Schema{type: :string, description: "Refresh token"}
          },
          required: [:user, :access_token, :refresh_token]
        }
      },
      required: [:data],
      example: %{
        "data" => %{
          "user" => %{
            "id" => "a8b9c0d1-e2f3-4g5h-6i7j-8k9l0m1n2o3p",
            "email" => "user@example.com",
            "inserted_at" => "2025-10-25T12:00:00Z",
            "updated_at" => "2025-10-25T12:00:00Z"
          },
          "access_token" => "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9...",
          "refresh_token" => "gq9tNOJ8N6L7x4h2vb5ocavAo6BRLBHoQR6FDWvqZT4"
        }
      }
    })
  end

  defmodule RefreshTokenRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "RefreshTokenRequest",
      description: "Request to refresh access token",
      type: :object,
      properties: %{
        refresh_token: %Schema{type: :string, description: "Current refresh token"}
      },
      required: [:refresh_token],
      example: %{
        "refresh_token" => "gq9tNOJ8N6L7x4h2vb5ocavAo6BRLBHoQR6FDWvqZT4"
      }
    })
  end

  defmodule RefreshResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "RefreshResponse",
      description: "New token pair response",
      type: :object,
      properties: %{
        data: TokenPair
      },
      required: [:data],
      example: %{
        "data" => %{
          "access_token" => "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9...",
          "refresh_token" => "new_refresh_token_here"
        }
      }
    })
  end

  defmodule MessageResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "MessageResponse",
      description: "Success message response",
      type: :object,
      properties: %{
        message: %Schema{type: :string, description: "Success message"}
      },
      required: [:message],
      example: %{
        "message" => "Successfully logged out"
      }
    })
  end

  defmodule ErrorResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ErrorResponse",
      description: "Error response",
      type: :object,
      properties: %{
        error: %Schema{type: :string, description: "Error message"}
      },
      required: [:error],
      example: %{
        "error" => "Invalid email or password"
      }
    })
  end

  defmodule ValidationErrorResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ValidationErrorResponse",
      description: "Validation error response",
      type: :object,
      properties: %{
        errors: %Schema{
          type: :object,
          description: "Field-specific validation errors",
          additionalProperties: %Schema{
            type: :array,
            items: %Schema{type: :string}
          }
        }
      },
      required: [:errors],
      example: %{
        "errors" => %{
          "email" => ["must have the @ sign and no spaces"],
          "password" => ["should be at least 8 character(s)"]
        }
      }
    })
  end
end
