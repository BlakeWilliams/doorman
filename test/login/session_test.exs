defmodule Doorman.Login.SessionTest do
  use Doorman.ConnCase

  alias Doorman.Login.Session

  @valid_id 1
  @invalid_id 2
  @valid_secret "abc"
  @invalid_secret "def"

  defmodule SuccessRepoTemplate do
    def generate_get_by(expected_secret) do
      fn (Fake, opts) ->
        id = Keyword.get(opts, :id)
        secret = Keyword.get(opts, :session_secret)
        if id == 1 && secret == expected_secret do
          %{}
        else
          nil
        end
      end
    end
  end

  defmodule FakeSuccessRepo do
    def get_by(Fake, opts) do
      SuccessRepoTemplate.generate_get_by("abc").(Fake, opts)
    end
  end

  defmodule NilSuccessRepo do
    def get_by(Fake, opts) do
      SuccessRepoTemplate.generate_get_by(nil).(Fake, opts)
    end
  end

  test "login/1 sets :user_id on conn.session", %{conn: conn} do
    conn = Session.login(conn, %{id: 1, session_secret: "abc"})

    assert Plug.Conn.get_session(conn, :user_id) == 1
    assert Plug.Conn.get_session(conn, :session_secret) == "abc"
  end

  test "get_current_user/1 returns user when exists", %{conn: conn} do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @valid_id)
      |> Plug.Conn.put_session(:session_secret, @valid_secret)

    assert Session.get_current_user(conn)
  end

  test "get_current_user/1 accepts nil as a session_secret", %{conn: conn} do
    Mix.Config.persist([doorman: %{repo: NilSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @valid_id)
      |> Plug.Conn.put_session(:session_secret, nil)

    assert Session.get_current_user(conn)
  end

  test "get_current_user/1 won't accept just any session_secret just because this is set to nil", %{conn: conn} do
    Mix.Config.persist([doorman: %{repo: NilSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @valid_id)
      |> Plug.Conn.put_session(:session_secret, "abc")

    refute Session.get_current_user(conn)
  end

  test "get_current_user/1 won't accept a nil session_secret if this is not set to nil", %{conn: conn} do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @valid_id)
      |> Plug.Conn.put_session(:session_secret, nil)

    refute Session.get_current_user(conn)
  end

  test "get_current_user/1 returns nil when user does not exist", %{conn: conn} do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @invalid_id)
      |> Plug.Conn.put_session(:session_secret, @valid_secret)

    refute Session.get_current_user(conn)
  end

  test "get_current_user/1 returns nil when session_key does not match", %{conn: conn} do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @valid_id)
      |> Plug.Conn.put_session(:session_secret, @invalid_secret)

    refute Session.get_current_user(conn)
  end

  test "get_current_user/1 returns nil when session_key and id do not match", %{conn: conn} do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @invalid_id)
      |> Plug.Conn.put_session(:session_secret, @invalid_secret)

    refute Session.get_current_user(conn)
  end
end
