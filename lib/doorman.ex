defmodule Doorman do
  @moduledoc """
  A plug for finding the current user based on the strategy passed to `init/1`.

  The strategy passed in must implmenent the `Doorman.Login` behaviour.

  ## Example

  ```
  plug Doorman, Doorman.Login.Session
  ```
  """
  @behaviour Plug
  import Plug.Conn

  def init(nil) do
    raise ArgumentError, """
    `plug Doorman` must be passed a module that implements the `Doorman.Login`
    behaviour.

    You may want `plug Doorman, Doorman.Login.Auth`
    """
  end
  def init(strategy) do
    strategy
  end

  def call(conn, strategy) do
    case strategy.find_user(conn) do
      {:ok, user} ->
        conn |> assign(:current_user, user)
      {:error, _} ->
        conn |> assign(:current_user, nil)
    end
  end
end
