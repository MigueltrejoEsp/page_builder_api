defmodule PageBuilderApiWeb.HealthCheckController do
  use PageBuilderApiWeb, :controller

  def run(conn, _params) do
    conn
    |> Plug.Conn.send_resp(200, "Healthy")
    |> Plug.Conn.halt()
  end
end
