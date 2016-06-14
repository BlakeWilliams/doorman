defmodule Doorman.Auth.Bcrypt do
  @moduledoc """
  Provides functions for hashing passwords and authenticating users using
  [Comonin.Bcrypt](https://hexdocs.pm/comeonin/Comeonin.Bcrypt.html).

  This module assumes that you have a virtual field named `password`, and a
  database backed string field named `hashed_password`.

  ## Usage

  In an Ecto model call `use Doorman.Auth.Bcrypt`. This will add two functions
  to your module. `hash_password/1` and `authenticate/2`.

  ## Example

  ```
  defmodule User do
    use  Ecto.Schema
    use Doorman.Auth.Bcrypt

    import Ecto.Changeset

    def create_changeset(struct, changes) do
      struct
        |> cast(changes, ~w(email password))
        |> hash_password
    end
  end
  ```

  To authenticate a user in your application, you can use `authenticate/2`:

  ```
  user = Repo.get(User, 1)
  User.authenticate(user, "password")
  ```
  """
  alias Comeonin.Bcrypt
  alias Ecto.Changeset

  @virtual_field :password
  @database_field :hashed_password

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: [hash_password: 1]

      def authenticate(user, password) do
        unquote(__MODULE__).authenticate(user, password)
      end
    end
  end

  @doc """
  Takes a changeset and turns the virtual `password` field into a
  `hashed_password` change on the changeset.
  """
  def hash_password(changeset) do
    password = Ecto.Changeset.get_change(changeset, @virtual_field)

    if password do
      hashed_password = Bcrypt.hashpwsalt(password)
      changeset
      |> Changeset.put_change(@database_field, hashed_password)
    else
      changeset
    end
  end

  @doc """
  Compares the given `password` against the given `user`'ss password.
  """
  def authenticate(user, password) do
    Bcrypt.checkpw(password, user.hashed_password)
  end
end
