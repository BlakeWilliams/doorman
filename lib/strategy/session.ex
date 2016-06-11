defmodule Doorman.Strategy.Session do
  def login(conn, user) do
    conn
    |> Plug.Conn.put_session(:user_id, user.id)
  end

  def find_user(conn) do
    id = Plug.Conn.get_session(conn, :user_id)
    repo = Application.get_env(:doorman, :repo) # Constable.Repo
    user_module = Application.get_env(:doorman, :user_module) # Constable.User

    case repo.get(user_module, id) do
      nil -> {:error, "Could not find user"}
      user -> {:ok, user}
    end
  end
end
