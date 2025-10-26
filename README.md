# PageBuilderApi

REST API for the Page Builder web application built with Phoenix Framework.

## Quick Start

**Prerequisites:**
- Elixir 1.14+ and Erlang/OTP 25+
- Docker and Docker Compose
- PostgreSQL (via Docker)

**Setup:**

```bash
# Start the database
docker-compose up -d

# Install dependencies and setup database
mix setup

# Start the Phoenix server
mix phx.server
```

The API will be available at `http://localhost:4000`

**Swagger Documentation:** Visit `http://localhost:4000/api/swagger` for interactive API documentation.

## Authentication

This API uses **JWT-based authentication** with a dual-token pattern:

- **Access Tokens**: Short-lived (1 hour), stateless JWT for API requests
- **Refresh Tokens**: Long-lived (30 days), database-backed, revocable

**Key Features:**
- Secure password hashing with bcrypt
- Token refresh mechanism for seamless user experience
- Forced logout (single device or all devices)
- CORS protection for allowed origins
- Rate limiting on auth endpoints (5 registrations/hour, 20 logins/hour)

**Available Endpoints:**

```
Public:
  POST   /api/auth/register       - Create new account
  POST   /api/auth/login          - Login and get tokens
  POST   /api/auth/refresh        - Refresh access token
  POST   /api/auth/logout         - Logout (revoke refresh token)

Protected (requires access token):
  POST   /api/auth/logout-all     - Logout from all devices
  GET    /api/user/profile        - Get current user
  PUT    /api/user/profile        - Update user
  DELETE /api/user/profile        - Delete account
```

**Basic Usage:**

```javascript
// 1. Register/Login - Get tokens
const response = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: 'user@example.com', password: 'password123' })
});
const { access_token, refresh_token } = (await response.json()).data;

// 2. Make authenticated requests
const profile = await fetch('/api/user/profile', {
  headers: { 'Authorization': `Bearer ${access_token}` }
});

// 3. Refresh when access token expires
const newTokens = await fetch('/api/auth/refresh', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ refresh_token })
});

// 4. Logout
await fetch('/api/auth/logout', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ refresh_token })
});
```

## Development

**Run in development mode:**
```bash
mix phx.server
# or with interactive shell
iex -S mix phx.server
```

**Database commands:**
```bash
mix ecto.migrate          # Run migrations
mix ecto.rollback         # Rollback last migration
mix ecto.reset            # Drop, create, and migrate database
```

**Generate Guardian secret:**
```bash
mix guardian.gen.secret
```

## Configuration

**CORS (Cross-Origin):**
Edit `lib/page_builder_api_web/endpoint.ex` to allow your frontend domain:
```elixir
plug CORSPlug,
  origin: ["http://localhost:3000", "https://yourapp.com"\],
  credentials: true
```

**Rate Limiting:**
Configure in `config/config.exs`:
```elixir
config :page_builder_api, :enable_rate_limiting, true
```

**Guardian (JWT):**
Set secret key in environment:
```bash
export GUARDIAN_SECRET_KEY="your-secret-key"
```

## Testing

```bash
mix test              # Run all tests
mix test --cover      # Run with coverage
mix test path/to/test # Run specific test file
```

Current test coverage: **57 tests, 0 failures** ✅

## Project Structure

```
lib/
├── page_builder_api/
│   └── authentication/          # Auth context
│       ├── user.ex              # User schema
│       └── refresh_token.ex     # Refresh token schema
├── page_builder_api_web/
│   ├── controllers/             # HTTP controllers
│   ├── plugs/                   # Custom plugs (auth, rate limit)
│   └── router.ex                # Route definitions
priv/
└── repo/migrations/             # Database migrations
test/                            # Test suite
```

## Learn More

- Phoenix Framework: https://www.phoenixframework.org/
- Guardian (JWT): https://github.com/ueberauth/guardian
- Elixir: https://elixir-lang.org/
