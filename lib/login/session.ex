defmodule Doorman.Login.Session do
  use Doorman.Login

  @session_key :user_id

  @doc """
  Logs in given user by setting `:user_id` on the session of passed in `conn`.
  """
  def login(conn, user) do
    Plug.Conn.put_session(conn, @session_key, user.id)
  end

  @doc """
  Logs out current user.
  """
  def logout(conn) do
    Plug.Conn.delete_session(conn, @session_key)
  end

  @doc """
  Returns the current user or nil based on `:user_id` in the session.
  """
  def get_current_user(conn) do
    id = Plug.Conn.get_session(conn, @session_key)
    repo = Application.get_env(:doorman, :repo)
    user_module = Application.get_env(:doorman, :user_module)

    if id != nil do
      repo.get(user_module, id)
    end
  end
end
