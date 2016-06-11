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

  test "login sets :user_id on conn.session" do
    conn
    |> Plug.Conn.put_session(:user_id, @valid_id)

    conn = Session.login(conn, %{id: 1})

    assert Plug.Conn.get_session(conn, :user_id) == 1
  end

  test "find_user returns {:ok, user} when exists" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @valid_id)

    assert {:ok, _user} = Session.find_user(conn)
  end

  test "find_user returns {:error, reason} when does not exist" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @invalid_id)

    expected_reason = Session.errors[:no_user]
    assert {:error, ^expected_reason} = Session.find_user(conn)
  end

  test "find_user returns error when session user_id is nil" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn

    expected_reason = Session.errors[:nil_user_id]
    assert {:error, ^expected_reason} = Session.find_user(conn)
  end
end
