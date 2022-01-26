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

  defmodule CustomFieldFakeUser do
    use Ecto.Schema
    import Ecto.Changeset

    schema "fake_users" do
      field :password_hash
      field :password, :string, virtual: true
    end

    def create_changeset(changes) do
      %__MODULE__{}
      |> cast(changes, ~w(password))
      |> Doorman.Auth.Bcrypt.hash_password(field_name: :password_hash)
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

  test "hash_password set encrypted password with a custom field name on changeset when virtual field is present" do
    changeset = CustomFieldFakeUser.create_changeset(%{password: "pass123"})

    assert changeset.changes[:password_hash]
  end

  test "hash_password does not set encrypted password with a custom field name on changeset when virtual field is present" do
    changeset = CustomFieldFakeUser.create_changeset(%{})

    refute changeset.changes[:password_hash]
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
