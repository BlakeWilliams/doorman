defmodule Doorman.RequireLogin do
  import Plug.Conn

  def init(unauthenticated_handler \\ &Plug.Conn.halt/1) do
    unauthenticated_handler
  end

  def call(conn, unauthenticated_handler \\ &stop/1) do
    if conn.assigns[:current_user] == nil do
      unauthenticated_handler.(conn)
    else
      conn
    end
  end

  defp stop(conn) do
    conn |> put_status(:unauthorized) |> halt
  end
end
