defmodule Doorman.Login do
  @callback login(%Plug.Conn{}, %{id: Integer}) :: %Plug.Conn{}
  @callback find_user(%Plug.Conn{}) :: %Plug.Conn{}
end
