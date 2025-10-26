defmodule PageBuilderApiWeb.Plugs.RateLimit do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, opts) do
    # Check if rate limiting is enabled (can be disabled in test environment)
    if Application.get_env(:page_builder_api, :enable_rate_limiting, true) do
      check_rate_limit(conn, opts)
    else
      conn
    end
  end

  defp check_rate_limit(conn, opts) do
    key = rate_limit_key(conn, opts)
    max_requests = Keyword.get(opts, :max_requests, 5)
    # 1 hour default
    interval_ms = Keyword.get(opts, :interval_ms, 3_600_000)

    case Hammer.check_rate(key, interval_ms, max_requests) do
      {:allow, _count} ->
        conn

      {:deny, _limit} ->
        conn
        |> put_status(:too_many_requests)
        |> put_view(json: PageBuilderApiWeb.ErrorJSON)
        |> render(:"429")
        |> halt()
    end
  end

  defp rate_limit_key(conn, opts) do
    scope = Keyword.get(opts, :scope, :default)
    ip = get_ip(conn)
    "rate_limit:#{scope}:#{ip}"
  end

  defp get_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [ip | _] -> ip
      [] -> conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end
end
