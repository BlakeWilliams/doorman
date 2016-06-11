defmodule DoormanTest do
  use Doorman.ConnCase
  doctest Doorman

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

  defmodule FakeLoginStrategy do
    def login(conn, user), do: {conn, user}
  end

  test "login delegates to configured login_strategy" do
    Mix.Config.persist([doorman: %{login_strategy: FakeLoginStrategy}])

    fake_conn = %{conn: true}
    fake_user = %{user: true}

    {conn, user} = Doorman.login(fake_conn, fake_user)

    assert conn == fake_conn
    assert user == fake_user
  end

  test "init/1 strategy defaults to configured strategy" do
    Mix.Config.persist([doorman: %{login_strategy: FakeLoginStrategy}])

    assert Doorman.init(nil) == FakeLoginStrategy
  end

  test "init/1 strategy uses passed in strategy if provided" do
    assert Doorman.init(Fake) == Fake
  end

  test "using session strategy with valid id returns user" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])

    conn = conn
      |> Plug.Conn.put_session(:user_id, @valid_id)
      |> Doorman.call(Session)

    assert conn.assigns.current_user == %{}
  end

  test "using session strategy with invalid id returns nil" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])

    conn = conn
      |> Plug.Conn.put_session(:user_id, @invalid_id)
      |> Doorman.call(Session)

    assert conn.assigns.current_user == nil
  end
end
