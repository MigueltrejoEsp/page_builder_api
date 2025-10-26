defmodule PageBuilderApiWeb.Plugs.RateLimitTest do
  use PageBuilderApiWeb.ConnCase, async: false

  alias PageBuilderApiWeb.Plugs.RateLimit

  describe "call/2" do
    test "allows requests when rate limiting is disabled", %{conn: conn} do
      # Rate limiting is disabled in test config
      opts = RateLimit.init(max_requests: 1, interval_ms: 1000)

      # Should allow multiple requests
      conn1 = RateLimit.call(conn, opts)
      refute conn1.halted

      conn2 = RateLimit.call(conn, opts)
      refute conn2.halted

      conn3 = RateLimit.call(conn, opts)
      refute conn3.halted
    end

    @tag :rate_limit_enabled
    test "blocks requests after exceeding rate limit when enabled", %{conn: base_conn} do
      # Temporarily enable rate limiting for this test
      original_config = Application.get_env(:page_builder_api, :enable_rate_limiting)
      Application.put_env(:page_builder_api, :enable_rate_limiting, true)

      try do
        opts = RateLimit.init(max_requests: 2, interval_ms: 60_000, scope: :test_scope)

        # First request should pass
        conn1 =
          base_conn
          |> Map.put(:params, %{"_format" => "json"})
          |> Plug.Parsers.call(Plug.Parsers.init(parsers: [:json], json_decoder: Jason))
          |> RateLimit.call(opts)

        refute conn1.halted

        # Second request should pass
        conn2 =
          base_conn
          |> recycle()
          |> Map.put(:params, %{"_format" => "json"})
          |> Plug.Parsers.call(Plug.Parsers.init(parsers: [:json], json_decoder: Jason))
          |> RateLimit.call(opts)

        refute conn2.halted

        # Third request should be blocked
        conn3 =
          base_conn
          |> recycle()
          |> Map.put(:params, %{"_format" => "json"})
          |> Plug.Parsers.call(Plug.Parsers.init(parsers: [:json], json_decoder: Jason))
          |> RateLimit.call(opts)

        assert conn3.halted
        assert conn3.status == 429
      after
        # Restore original config
        Application.put_env(:page_builder_api, :enable_rate_limiting, original_config)

        # Clean up Hammer state
        Hammer.delete_buckets("rate_limit:test_scope:127.0.0.1")
      end
    end

    @tag :rate_limit_enabled
    test "uses x-forwarded-for header if present when enabled", %{conn: base_conn} do
      original_config = Application.get_env(:page_builder_api, :enable_rate_limiting)
      Application.put_env(:page_builder_api, :enable_rate_limiting, true)

      try do
        opts = RateLimit.init(max_requests: 1, interval_ms: 60_000, scope: :test_x_forwarded)

        # First request should pass
        conn1 =
          base_conn
          |> put_req_header("x-forwarded-for", "192.168.1.1")
          |> Map.put(:params, %{"_format" => "json"})
          |> Plug.Parsers.call(Plug.Parsers.init(parsers: [:json], json_decoder: Jason))
          |> RateLimit.call(opts)

        refute conn1.halted

        # Second request with same IP should be blocked
        conn2 =
          base_conn
          |> recycle()
          |> put_req_header("x-forwarded-for", "192.168.1.1")
          |> Map.put(:params, %{"_format" => "json"})
          |> Plug.Parsers.call(Plug.Parsers.init(parsers: [:json], json_decoder: Jason))
          |> RateLimit.call(opts)

        assert conn2.halted
        assert conn2.status == 429
      after
        Application.put_env(:page_builder_api, :enable_rate_limiting, original_config)
        Hammer.delete_buckets("rate_limit:test_x_forwarded:192.168.1.1")
      end
    end
  end
end
