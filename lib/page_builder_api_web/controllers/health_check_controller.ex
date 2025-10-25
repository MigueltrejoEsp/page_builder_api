defmodule PageBuilderApiWeb.HealthCheckController do
  use PageBuilderApiWeb, :controller

  def run(conn, params) do
    conn
    |> Plug.Conn.send_resp(200, "Healthy")
    |> Plug.Conn.halt()
  end
end
