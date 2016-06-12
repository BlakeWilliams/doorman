defmodule Doorman.Login do
  @moduledoc """
  This module specifies the behavior that login strategies must implement.
  """

  @doc """
  Expects the second argument to be an Ecto struct that has an `id` field.
  """
  @callback login(Plug.Conn.t, struct) :: Plug.Conn.t

  @callback find_user(Plug.Conn.t) :: Plug.Conn.t
end
