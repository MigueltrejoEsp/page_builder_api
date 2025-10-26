# PageBuilderApi

Api for Page Build web application.

## Table of Contents

- [Setup](#setup)
- [Authentication System](#authentication-system)
  - [Overview](#overview)
  - [API Endpoints](#api-endpoints)
  - [Usage Examples](#usage-examples)
- [Security Features](#security-features)
  - [CORS Configuration](#cors-configuration)
  - [Rate Limiting](#rate-limiting)
- [Development](#development)
- [Testing](#testing)

## Setup

To start your Phoenix server:

  * Start the database using Docker Compose: `docker-compose up -d`
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

**Note:** The `docker-compose.yml` file provides a PostgreSQL database configured and ready for development. Make sure Docker is installed and running on your system.

## Authentication System

### Overview

The authentication system provides JWT (JSON Web Token) based authentication for securing your REST API endpoints. It includes user registration, login, and profile management.

**Features:**
- User registration with email and password
- Secure password hashing using bcrypt
- JWT token generation with 30-day expiration
- Protected routes requiring authentication
- User profile management (view, update, delete)
- CORS protection (configured for localhost development)
- Rate limiting on registration and login endpoints
- Client-side logout (stateless JWT approach)

### API Endpoints

#### Public Endpoints (No Authentication Required)

##### Register a New User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (201 Created):**
```json
{
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "inserted_at": "2025-10-25T12:00:00Z",
      "updated_at": "2025-10-25T12:00:00Z"
    },
    "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9..."
  }
}
```

##### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "inserted_at": "2025-10-25T12:00:00Z",
      "updated_at": "2025-10-25T12:00:00Z"
    },
    "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### Protected Endpoints (Authentication Required)

All protected endpoints require a Bearer token in the Authorization header:
```http
Authorization: Bearer <your-jwt-token>
```

##### Get Current User Profile
```http
GET /api/user/profile
Authorization: Bearer <your-jwt-token>
```

**Response (200 OK):**
```json
{
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "inserted_at": "2025-10-25T12:00:00Z",
    "updated_at": "2025-10-25T12:00:00Z"
  }
}
```

##### Update User Profile
```http
PUT /api/user/profile
Authorization: Bearer <your-jwt-token>
Content-Type: application/json

{
  "email": "newemail@example.com"
}
```

**Response (200 OK):**
```json
{
  "data": {
    "id": "uuid",
    "email": "newemail@example.com",
    "inserted_at": "2025-10-25T12:00:00Z",
    "updated_at": "2025-10-25T12:00:00Z"
  }
}
```

##### Delete User Account
```http
DELETE /api/user/profile
Authorization: Bearer <your-jwt-token>
```

**Response (204 No Content)**

### Usage Examples

#### Using cURL

**Register:**
```bash
curl -X POST http://localhost:4000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

**Login:**
```bash
curl -X POST http://localhost:4000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

**Get Profile (with token):**
```bash
TOKEN="your-jwt-token-here"
curl -X GET http://localhost:4000/api/user/profile \
  -H "Authorization: Bearer $TOKEN"
```

**Update Profile:**
```bash
TOKEN="your-jwt-token-here"
curl -X PUT http://localhost:4000/api/user/profile \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"newemail@example.com"}'
```

**Logout (Client-Side):**
```bash
# Simply remove the token from storage
# No server-side endpoint needed - JWTs are stateless
```

#### Using JavaScript/Fetch

```javascript
// Register
const register = async (email, password) => {
  const response = await fetch('http://localhost:4000/api/auth/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });
  return response.json();
};

// Login
const login = async (email, password) => {
  const response = await fetch('http://localhost:4000/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });
  const data = await response.json();
  // Store token for future requests
  localStorage.setItem('token', data.data.token);
  return data;
};

// Get Profile
const getProfile = async () => {
  const token = localStorage.getItem('token');
  const response = await fetch('http://localhost:4000/api/user/profile', {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  return response.json();
};

// Update Profile
const updateProfile = async (email) => {
  const token = localStorage.getItem('token');
  const response = await fetch('http://localhost:4000/api/user/profile', {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ email })
  });
  return response.json();
};

// Logout (Client-Side Only)
const logout = () => {
  // Simply remove the token from storage
  // No server request needed - JWTs are stateless
  localStorage.removeItem('token');
  // Optional: redirect to login page or clear user state
};
```

### Logout Implementation

This API uses a **stateless JWT approach**, meaning logout is handled entirely on the client side:

1. **No server-side logout endpoint** - JWTs are self-contained and valid until expiration
2. **Client removes the token** - Delete from localStorage/sessionStorage/cookies
3. **Security** - Use HTTPS in production and set appropriate token expiration times

**Client-Side Logout Example:**
```javascript
// Remove token from storage
localStorage.removeItem('token');

// Clear any user state in your app
setUser(null);

// Redirect to login page
window.location.href = '/login';
```

**Important Notes:**
- Tokens remain valid until their expiration time (30 days by default)
- For better security, consider shorter expiration times (e.g., 1 hour) with refresh tokens
- Always use HTTPS in production to prevent token interception

### Error Responses

#### Validation Errors (422 Unprocessable Entity)
```json
{
  "errors": {
    "email": ["must have the @ sign and no spaces"],
    "password": ["should be at least 8 character(s)"]
  }
}
```

#### Unauthorized (401)
```json
{
  "error": "Invalid email or password"
}
```

or

```json
{
  "error": "unauthenticated"
}
```

### Password Requirements

- Minimum length: 8 characters
- Maximum length: 80 characters

### Email Requirements

- Must contain @ sign
- No spaces allowed
- Maximum length: 160 characters
- Must be unique

### Token Information

- **Type:** JWT (JSON Web Token)
- **Expiration:** 30 days
- **Algorithm:** HS512
- **Storage:** Client-side (localStorage, sessionStorage, or secure cookie)

## Security Features

### CORS Configuration

The API has CORS (Cross-Origin Resource Sharing) enabled to control which domains can access the endpoints. This is configured in `lib/page_builder_api_web/endpoint.ex`.

**Default Allowed Origins:**
- `http://localhost:3000` (React/Vite default)
- `http://localhost:5173` (Vite default)

**Configuration:**
```elixir
plug CORSPlug,
  origin: ["http://localhost:3000", "http://localhost:5173"],
  credentials: true,
  max_age: 86400,
  headers: ["Authorization", "Content-Type", "Accept", "Origin"]
```

For production, update the `origin` list to include your production frontend domain:
```elixir
origin: ["https://yourapp.com"],
```

### Rate Limiting

Rate limiting is implemented to protect against abuse and brute-force attacks. It uses the Hammer library with ETS backend.

**Rate Limits:**
- **Registration:** 5 requests per hour per IP address
- **Login:** 20 requests per hour per IP address

**Configuration:**

The rate limiting can be disabled in test environment by setting in `config/test.exs`:
```elixir
config :page_builder_api, :enable_rate_limiting, false
```

For production, ensure rate limiting is enabled (default):
```elixir
config :page_builder_api, :enable_rate_limiting, true
```

**Hammer Configuration** (`config/config.exs`):
```elixir
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}
```

**Rate Limit Response:**
```json
{
  "error": "Too many requests. Please try again later."
}
```
HTTP Status: `429 Too Many Requests`

## Development

### Configuration

The authentication system uses Guardian for JWT management. Configuration can be found in:

- `config/config.exs` - Base configuration
- `config/dev.exs` - Development secret key
- `config/prod.exs` - Production secret key (should use environment variable)

For production, set the `GUARDIAN_SECRET_KEY` environment variable:

```bash
export GUARDIAN_SECRET_KEY="your-secret-key-here"
```

Generate a secret key with:
```bash
mix guardian.gen.secret
```

### Database

Run migrations to create the users table:
```bash
mix ecto.migrate
```

Reset database (development only):
```bash
mix ecto.reset
```

## Testing

Run the test suite:
```bash
mix test
```

Run tests with coverage:
```bash
mix test --cover
```

The test suite includes:
- Authentication context tests (user management, registration, login)
- Controller tests (all API endpoints)
- Authorization tests (protected routes)
- Validation tests (email format, password length, etc.)
- Rate limiting tests (plug behavior with enabled/disabled states)

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
  * Guardian (JWT): https://github.com/ueberauth/guardian
