defmodule Doorman.RequireLoginTest do
  use Doorman.ConnCase

  test "require login does not halt when user is authenticated" do
    conn = conn
      |> Plug.Conn.assign(:current_user, %{})
      |> Doorman.RequireLogin.call

    refute conn.halted
  end

  test "require login halts when user is not authenticated" do
    conn = conn
      |> Plug.Conn.assign(:current_user, nil)
      |> Doorman.RequireLogin.call

    assert conn.halted
    assert conn.status == 401
  end

  test "require login accepts handler function that is called when user is unauthenticated" do
    conn = conn
      |> Plug.Conn.assign(:current_user, nil)
      |> Doorman.RequireLogin.call(fn(conn) ->
        conn |> Plug.Conn.put_status(:forbidden) |> Plug.Conn.halt
      end)

    assert conn.halted
    assert conn.status == 403
  end
end
