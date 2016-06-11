defmodule DoormanTest do
  use Doorman.ConnCase
  doctest Doorman

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

  test "using session strategy with valid id returns user" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])

    conn = conn
      |> Plug.Conn.put_session(:user_id, @valid_id)
      |> Doorman.call(Doorman.Strategy.Session)

    assert conn.assigns.current_user == %{}
  end

  test "using session strategy with invalid id returns nil" do
    Mix.Config.persist([doorman: %{repo: FakeSuccessRepo, user_module: Fake}])

    conn = conn
      |> Plug.Conn.put_session(:user_id, @invalid_id)
      |> Doorman.call(Doorman.Strategy.Session)

    assert conn.assigns.current_user == nil
  end
end
