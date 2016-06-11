defmodule Doorman do
  import Plug.Conn

  # Public API

  def login(conn, user) do
    strategy = Application.get_env(:doorman, :login_strategy)
    strategy.login(conn, user)
  end

  # Plug Callbacks

  def init(nil) do
    Application.get_env(:doorman, :login_strategy)
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
