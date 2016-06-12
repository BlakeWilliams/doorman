defmodule Doorman.Auth.Bcrypt do
  @moduledoc """
  Provides functions for hashing passwords and authenticating users using
  [Comonin.Bcrypt](https://hexdocs.pm/comeonin/Comeonin.Bcrypt.html).

  ## Usage
  In an Ecto model call `use Doorman.Auth.Bcrypt`. This will add two functions
  to your module. `hash_password/1` and `authenticate/2`.

  You can also pass options to the `use` call to specify which virtual field to
  read from and which database field to put the hashed password on.

  The default value for `virtual_field` is `password` and the default for
  `database_field` is `password_digest`.

  ## Example

  To hash the `passcode` field and save it as `hashed_passcode` you could do
  the following:

  ```
  defmodule User do
    use  Ecto.Schema
    use Doorman.Auth.Bcrypt, virtual_field: "passcode",
      database_field: "hashed_passcode"

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

  defmacro __using__(options) do
    options = Map.merge(default_options, Map.new(options))

    quote do
      def hash_password(changeset) do
        password = Ecto.Changeset.get_change(
          changeset,
          unquote(options[:virtual_field])
        )

        if password do
          hashed_password = Bcrypt.hashpwsalt(password)
          changeset
          |> Ecto.Changeset.put_change(
            unquote(options[:database_field]),
            hashed_password
          )
        else
          changeset
        end
      end

      def authenticate(user, password) do
        Bcrypt.checkpw(password, user.password_digest)
      end
    end
  end

  defp default_options do
    %{
      virtual_field: :password,
      database_field: :password_digest,
    }
  end
end
