defmodule Doorman.RequireLogin do
  @moduledoc """
  A plug that ensures the user is authenticated.

  This plug accepts a handler function when used that is called when a user is
  unauthenticated. This function receives `conn` and should return
  `Plug.Conn.halt/1`.

  The default handler sets the status code to `422` and halts.

  ## Example

  ```
  plug Doorman.RequireLogin, &require_login/1

  defp require_login(conn) do
    conn
    |> redirect(to: session_path(conn, :new))
    |> Plug.Conn.halt
  end
  ```
  """
  @behaviour Plug
  import Plug.Conn

  def init(unauthenticated_handler \\ &stop/1) do
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
