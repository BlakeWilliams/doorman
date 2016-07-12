defmodule Doorman.Auth.BcryptTest do
  use Doorman.ConnCase

  alias Doorman.Auth.Bcrypt

  defmodule FakeUser do
    use Ecto.Schema
    import Ecto.Changeset

    schema "fake_users" do
      field :hashed_password
      field :password, :string, virtual: true
    end

    def create_changeset(changes) do
      %__MODULE__{}
      |> cast(changes, ~w(password))
      |> Doorman.Auth.Bcrypt.hash_password
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

  test "hashed password field can be customised" do
    hashed_password_field = Application.get_env(:doorman, :hashed_password_field)

    try do
      Application.put_env(:doorman, :hashed_password_field, :encrypted_password)

      changeset = FakeUser.create_changeset(%{password: "foobar"})

      refute changeset.changes[:hashed_password]
      assert changeset.changes[:encrypted_password]
    after
      Application.put_env(:doorman, :hashed_password_field, hashed_password_field)
    end
  end

  test "authenticate returns true when password matches" do
    password = "secure"
    user = %FakeUser{hashed_password: Comeonin.Bcrypt.hashpwsalt(password)}

    assert Bcrypt.authenticate(user, password)
  end

  test "authenticate returns false when password does not match" do
    password = "secure"
    user = %FakeUser{hashed_password: Comeonin.Bcrypt.hashpwsalt(password)}

    refute Bcrypt.authenticate(user, "wrong")
  end
end
