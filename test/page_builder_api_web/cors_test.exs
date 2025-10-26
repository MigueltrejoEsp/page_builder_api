defmodule PageBuilderApiWeb.CORSTest do
  use PageBuilderApiWeb.ConnCase

  describe "CORS Configuration" do
    test "sets CORS headers for localhost:3000 origin", %{conn: conn} do
      conn =
        conn
        |> put_req_header("origin", "http://localhost:3000")
        |> post(~p"/api/auth/login", %{email: "test@test.com", password: "wrong"})

      assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:3000"]
      assert get_resp_header(conn, "access-control-allow-credentials") == ["true"]
    end

    test "sets CORS headers for localhost:5173 origin", %{conn: conn} do
      conn =
        conn
        |> put_req_header("origin", "http://localhost:5173")
        |> get(~p"/api/auth/register")

      assert get_resp_header(conn, "access-control-allow-origin") == ["http://localhost:5173"]
      assert get_resp_header(conn, "access-control-allow-credentials") == ["true"]
    end

    test "does not set CORS headers for unauthorized origins", %{conn: conn} do
      conn =
        conn
        |> put_req_header("origin", "http://evil-site.com")
        |> get(~p"/api/auth/login")

      # Should not include the origin in the response
      assert get_resp_header(conn, "access-control-allow-origin") == []
    end

    test "includes configured headers in CORS response", %{conn: conn} do
      conn =
        conn
        |> put_req_header("origin", "http://localhost:3000")
        |> post(~p"/api/auth/login", %{email: "test@test.com", password: "wrong"})

      # Verify credentials are allowed
      assert get_resp_header(conn, "access-control-allow-credentials") == ["true"]
    end
  end
end
