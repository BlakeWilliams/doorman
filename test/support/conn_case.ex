defmodule Doorman.ConnCase do
  use ExUnit.CaseTemplate

  @session_opts Plug.Session.init [
    store: :cookie,
    key: "foobar",
    encryption_salt: "salt",
    signing_salt: "signing salt",
  ]

  def build_conn do
    Plug.Test.conn(:get, "/")
    |> Plug.Session.call(@session_opts)
    |> Plug.Conn.fetch_session
  end

  setup _ do
    {:ok, %{conn: build_conn()}}
  end
end
