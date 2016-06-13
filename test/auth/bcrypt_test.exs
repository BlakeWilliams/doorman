defmodule Doorman.Auth.BcryptTest do
  use Doorman.ConnCase

  defmodule FakeUser do
    use Ecto.Schema
    use Doorman.Auth.Bcrypt
    import Ecto.Changeset

    schema "fake_users" do
      field :hashed_password
      field :password, :string, virtual: true
    end

    def create_changeset(changes) do
      %__MODULE__{}
      |> cast(changes, ~w(password))
      |> hash_password
    end
  end

  test "hash_password sets encrypted password on changeset when virtual field is present" do
    changeset = FakeUser.create_changeset(%{password: "foobar"})

    assert changeset.changes[:hashed_password]
  end

  test "hash_password does not set encrypted password on changeset when virtual field is not present" do
    changeset = FakeUser.create_changeset(%{})

    refute changeset.changes[:hashed_password]
  end

  test "authenticate returns true when password matches" do
    password = "secure"
    user = %FakeUser{hashed_password: Comeonin.Bcrypt.hashpwsalt(password)}

    assert FakeUser.authenticate(user, password)
  end

  test "authenticate returns false when password does not match" do
    password = "secure"
    user = %FakeUser{hashed_password: Comeonin.Bcrypt.hashpwsalt(password)}

    refute FakeUser.authenticate(user, "wrong")
  end
end
