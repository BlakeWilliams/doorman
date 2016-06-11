defmodule Doorman.ConnCase do
  defmacro __using__(_) do
    quote do
      use ExUnit.Case

      @session_opts Plug.Session.init [
        store: :cookie,
        key: "foobar",
        encryption_salt: "salt",
        signing_salt: "signing salt",
      ]

      def conn do
        conn = Plug.Test.conn(:get, "/")
          |> Plug.Session.call(@session_opts)
          |> Plug.Conn.fetch_session
      end
    end
  end
end
