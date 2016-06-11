defmodule Doorman do
  import Plug.Conn

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
