defmodule PageBuilderApiWeb.Schemas do
  alias OpenApiSpex.Schema

  # ============================================================================
  # REQUEST SCHEMAS (what clients send)
  # ============================================================================

  defmodule LoginRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "LoginRequest",
      description: "User login credentials",
      type: :object,
      properties: %{
        email: %Schema{
          type: :string,
          format: :email,
          description: "User email address"
        },
        password: %Schema{
          type: :string,
          description: "User password",
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

  defmodule RegisterRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "RegisterRequest",
      description: "User registration data",
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

  defmodule RefreshRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "RefreshRequest",
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

  defmodule LogoutRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "LogoutRequest",
      description: "Request to logout (revoke refresh token)",
      type: :object,
      properties: %{
        refresh_token: %Schema{type: :string, description: "Refresh token to revoke"}
      },
      required: [:refresh_token],
      example: %{
        "refresh_token" => "gq9tNOJ8N6L7x4h2vb5ocavAo6BRLBHoQR6FDWvqZT4"
      }
    })
  end

  # ============================================================================
  # RESPONSE SCHEMAS (what API returns)
  # ============================================================================

  defmodule LoginResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "LoginResponse",
      description: "Successful login response with user data and tokens",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            user: %Schema{
              type: :object,
              properties: %{
                id: %Schema{type: :string, format: :uuid},
                email: %Schema{type: :string, format: :email},
                inserted_at: %Schema{type: :string, format: :"date-time"},
                updated_at: %Schema{type: :string, format: :"date-time"}
              }
            },
            access_token: %Schema{type: :string, description: "JWT access token (1 hour)"},
            refresh_token: %Schema{type: :string, description: "Refresh token (30 days)"}
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

  defmodule RegisterResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "RegisterResponse",
      description: "Successful registration response with user data and tokens",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            user: %Schema{
              type: :object,
              properties: %{
                id: %Schema{type: :string, format: :uuid},
                email: %Schema{type: :string, format: :email},
                inserted_at: %Schema{type: :string, format: :"date-time"},
                updated_at: %Schema{type: :string, format: :"date-time"}
              }
            },
            access_token: %Schema{type: :string, description: "JWT access token (1 hour)"},
            refresh_token: %Schema{type: :string, description: "Refresh token (30 days)"}
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

  defmodule RefreshResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "RefreshResponse",
      description: "New token pair after successful refresh",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            access_token: %Schema{type: :string, description: "New JWT access token (1 hour)"},
            refresh_token: %Schema{
              type: :string,
              description: "New refresh token (30 days)"
            }
          },
          required: [:access_token, :refresh_token]
        }
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

  defmodule LogoutResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "LogoutResponse",
      description: "Successful logout response",
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

  defmodule LogoutAllResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "LogoutAllResponse",
      description: "Successful logout from all devices response",
      type: :object,
      properties: %{
        message: %Schema{type: :string, description: "Success message with device count"}
      },
      required: [:message],
      example: %{
        "message" => "Logged out from 3 device(s)"
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
      description: "Validation error response with field-specific errors",
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
