# Doorman

Modules and functions to make authentication with Plug/Phoenix and Ecto easy
without tons of configuration or boxing users into rigid framework.

The primary goal of Doorman is to build an opinionated interface and easy to use
API on top of flexible modules that can also be used directly.

You can find more in-depth [documentation here](https://hexdocs.pm/doorman/).

## Installation

Add doorman to your dependencies in `mix.exs`.

```elixir
def deps do
  [{:doorman, "~> 0.2.0"}]
end
```

Then add the configuration to `config/config.exs`.

```elixir
config :doorman,
  repo: MyApp.Repo,
  secure_with: Doorman.Auth.Bcrypt,
  user_module: MyApp.User,
```

## Phoenix Quick Start

First generate a user model with a `hashed_password` field.

```sh
$ mix ecto.gen.model User users email hashed_password 
```

Next, use `Doorman.Auth.Bcrypt` in your new `User` module and add a virtual
`password` field. `hash_password/1` is used in the changeset to hash our
password and put it into the changeset as `hashed_password`.


```elixir
defmodule MyApp.User do
  use MyApp.Web, :model
  import Doorman.Auth.Bcrypt, only: [hash_password: 1]

  schema "users" do
    field :email, :string
    field :hashed_password, :string
    field :password, :string, virtual: true

    timestamps
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(email password))
    |> hash_password
  end
end
```

Finally, we can add our plug so we can have access to `current_user` on
`conn.assigns`. A login strategy must to be passed in as an argument so Doorman
can find the current user.

```elixir
plug Doorman.Login.Session
```

### Creating Users

To create a user we can use the `MyApp.create_changeset/2` function we defined.

```elixir
defmodule MyApp.UserController do
  alias MyApp.User

  def new(conn, _params) do
    changeset = User.create_changeset(%User{})
    conn |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.create_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn |> redirect(to: "/")
      {:error, changeset} ->
        conn |> render("new.html", changeset: changeset)
    end
  end
end
```

### Logging in users

To login users we can use `Doorman.authenticate` and `Doorman.Session.login/2`.

```elixir
defmodule MyApp.SessionController do
  import Doorman.Login.Session, only: [login: 2]

  def create(conn, %{"email" => email, "password" => "password"})
    if user = Doorman.authenticate(email, password) do
      conn
      |> login(user) # Sets :user_id on conn's session
      |> put_flash(:notice, "Successfully logged in")
      |> redirect(to: "/")
    else
      conn
      |> put_flash(:error, "No user found with the provided credentials")
      |> render "new.html"
    end
  end
end
```

### Requiring Authentication

To require a user to be authenticated the `Doorman.RequireLogin` plug can be
used. It requires a function to be passed to it in order to handle
unauthenticated requests.

```elixir
plug Doorman.RequireLogin, fn(conn) ->
  conn |> redirect(to: "/") |> Plug.Conn.halt
end
```
