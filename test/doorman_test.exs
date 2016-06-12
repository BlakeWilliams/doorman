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

  test "init/1 raises an error when passed nil" do
    assert_raise ArgumentError, fn ->
      Doorman.init(nil)
    end
  end

  test "init/1 strategy uses passed in strategy" do
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
