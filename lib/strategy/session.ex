defmodule Doorman.Strategy.Session do
  def login(conn, user) do
    conn
    |> Plug.Conn.put_session(:user_id, user.id)
  end

  def find_user(conn) do
    id = Plug.Conn.get_session(conn, :user_id)
    repo = Application.get_env(:doorman, :repo)
    user_module = Application.get_env(:doorman, :user_module)

    if id == nil do
      {:error, errors[:nil_user_id]}
    else
      case repo.get(user_module, id) do
        nil -> {:error, errors[:no_user]}
        user -> {:ok, user}
      end
    end
  end

  def errors do
    %{
      nil_user_id: "Session's user_id can't be nil",
      no_user: "Could not find user"
    }
  end
end
