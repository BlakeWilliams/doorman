defmodule Doorman.Login.SessionTest do
  use Doorman.ConnCase

  alias Doorman.Login.Session

  @valid_id 1
  @invalid_id 2

  defmodule FakeSuccessRepo do
    def get(Fake, id) do
      if id == 1 do
        %{}
      else
        nil
      end
    end
  end

  test "login/1 sets :user_id on conn.session" do
    conn
    |> Plug.Conn.put_session(:user_id, @valid_id)

    conn = Session.login(conn, %{id: 1})

    assert Plug.Conn.get_session(conn, :user_id) == 1
  end

  test "get_current_user/1 returns user when exists" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @valid_id)

    assert Session.get_current_user(conn)
  end

  test "get_current_user/1 returns nil when user does not exist" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @invalid_id)

    refute Session.get_current_user(conn)
  end
end
