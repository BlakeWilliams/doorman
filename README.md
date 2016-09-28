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
  [{:doorman, "~> 0.5.1"}]
end
```

Then add the configuration to `config/config.exs`.

```elixir
config :doorman,
  repo: MyApp.Repo,
  secure_with: Doorman.Auth.Bcrypt,
  user_module: MyApp.User
```

## Phoenix Quick Start

First generate a user model with a `hashed_password` field.

```sh
$ mix phoenix.gen.model User users email hashed_password
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
`conn.assigns`. 99% of the time that means adding the `Doorman.Login.Session`
plug to your `:browser` pipeline:

```elixir
pipeline :browser do
  # ...
  plug Doorman.Login.Session
  # ...
end
```

### Creating Users

To create a user we can use the `MyApp.create_changeset/2` function we defined.

```elixir
defmodule MyApp.UserController do
  use MyApp.Web, :controller
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

To login users we can use `Doorman.authenticate` and `Doorman.Login.Session.login/2`.

```elixir
defmodule MyApp.SessionController do
  use Myapp.Web, :controller
  import Doorman.Login.Session, only: [login: 2]

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    if user = Doorman.authenticate(email, password) do
      conn
      |> login(user) # Sets :user_id on conn's session
      |> put_flash(:notice, "Successfully logged in")
      |> redirect(to: "/")
    else
      conn
      |> put_flash(:error, "No user found with the provided credentials")
      |> render("new.html")
    end
  end
end
```

### Requiring Authentication

To require a user to be authenticated you can build a simple plug around
`Doorman.logged_in?/1`.

```elixir
defmodule MyApp.RequireLogin do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if Doorman.logged_in?(conn) do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: "/login")
      |> halt
    end
  end
end
```
