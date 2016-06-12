defmodule Doorman.Login.Session do
  @moduledoc """
  Provides functions for logging in users and finding the current user for use
  in the Doorman plug.

  ## Example

  The following example assumes you have a configured `MyApp.User` module with
  using `Doorman.Auth.Bcrypt`.

  ```elixir
  defmodule MyApp.Controller do
    use MyApp.Web
    import Doorman.Login.Session, only: [login: 2]

    def create(conn, %{"email" => email, "password" => password}) do
      if user = MyApp.Repo.get_by(MyApp.User, email: email) do
        if MyApp.User.authenticate(user, password) do
          conn
          |> login(user) # Sets :user_id on conn's session
          |> put_flash(:notice, "Successfully logged in")
          |> redirect(to: "/")
        else
          conn
          |> put_flash(:error, "Password was incorrect")
          |> render "new.html"
        end
      else
        conn
        |> put_flash(:error, "No account for provided email found")
        |> render "new.html"
      end
    end
  end
  ```
  """
  @behaviour Doorman.Login

  @doc """
  Returns a `Plug.Conn` with `:user_id` put into the session by using the `id`
  field of `user`.
  """
  @spec login(Plug.Conn.t, struct) :: Plug.Conn.t
  def login(conn, user) do
    conn
    |> Plug.Conn.put_session(:user_id, user.id)
  end

  @doc """
  Returns either an error, or a user based on passed in `conn`.

  The configured `repo` and `user_module` options are used to find a user
  if `:user_id` is present in the session of `conn`.
  """
  @spec find_user(Plug.Conn.t) :: {:ok, struct} | {:error, String.t}
  def find_user(conn) do
    id = Plug.Conn.get_session(conn, :user_id)
    repo = Application.get_env(:doorman, :repo)
    user_module = Application.get_env(:doorman, :user_module)

    if id == nil do
      {:error, errors[:nil_user_id]}
    else
      case repo.get(user_module, id) do
        nil -> {:error, errors[:no_user]}
        user -> {:ok, user}
      end
    end
  end

  @doc """
  Returns the errors that `find_user` can return.

  Can be used to pattern match against errors for custom behavior. See source
  for available errors.
  """
  @spec errors :: %{nil_user_id: String.t, no_user: String.t}
  def errors do
    %{
      nil_user_id: "Session's user_id can't be nil",
      no_user: "Could not find user"
    }
  end
end
