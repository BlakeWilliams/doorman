defmodule Doorman.Login do
  @moduledoc """
  This module provides boilerplate for creating Plugs for authentication with
  Doorman.

  Modules that `use Doorman.Login` should implement a `get_current_user/1`
  function that accepts a connection and returns either the current user, or
  nil.

  Those modules should also implement helper functions such as login, logout,
  and etc. when applicable.

  ## Example

  ```
  defmodule MyApp.Auth do
    use Doorman.Login

    defp get_current_user(conn) do
      MyApp.Repo.get(MyApp.User, 1)
    end
  end
  ```

  Under the hood `Doorman.Login` implements the callbacks for the `Plug`
  behaviour. Both `init/1` and `call/2` are overridable.
  """

  defmacro __using__(_opts) do
    quote do
      @behaviour Plug
      @behaviour Doorman.Login
      import Plug.Conn

      @doc false
      def init(opts), do: opts

      @doc false
      def call(conn, _opts) do
        user = conn |> __MODULE__.get_current_user
        if user do
          conn |> assign(:current_user, user)
        else
          conn
        end
      end

      defoverridable [init: 1, call: 2]
    end
  end

  @doc """
  Returns either the current user or nil based on the state of the passed in
  `conn`.
  """
  @callback get_current_user(Plug.Conn.t) :: struct() | nil
end
