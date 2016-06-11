defmodule Doorman.Strategy.SessionTest do
  use Doorman.ConnCase

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

    conn = Doorman.Strategy.Session.login(conn, %{id: 1})

    assert Plug.Conn.get_session(conn, :user_id) == 1
  end

  test "find_user returns {:ok, user} when exists" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @valid_id)

    assert {:ok, _user} = Doorman.Strategy.Session.find_user(conn)
  end

  test "find_user returns {:error, reason} when does not exist" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])
    conn = conn
      |> Plug.Conn.put_session(:user_id, @invalid_id)

    assert {:error, _reason} = Doorman.Strategy.Session.find_user(conn)
  end
end
