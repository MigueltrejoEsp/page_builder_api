defmodule PageBuilderApiWeb.HealthCheckController do
  use PageBuilderApiWeb, :controller

  def run(conn, params) do
    IO.inspect(conn, label: :conn)
    IO.inspect(params, label: :params)

    conn
    |> Plug.Conn.send_resp(200, "Healthy")
    |> Plug.Conn.halt()
  end
end
