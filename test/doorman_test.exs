defmodule DoormanTest do
  use Doorman.ConnCase
  doctest Doorman

  @valid_id 1
  @invalid_id 2

  @valid_email "joe@dirt.com"

  defmodule FakeSuccessRepo do
    def get_by(Fake, email: "joe@dirt.com") do
      %{hashed_password: Comeonin.Bcrypt.hashpwsalt("password")}
    end
    def get_by(Fake, email: _email), do: nil

    def get(Fake, id) do
      if id == 1 do
        %{hashed_password: Comeonin.Bcypt.hashpwsalt("password")}
      else
        nil
      end
    end
  end

  test "authenticate/2 takes valid email and valid password and returns true" do
    Mix.Config.persist([doorman: %{
       repo: FakeSuccessRepo,
       user_module: Fake,
       secure_with: Doorman.Auth.Bcrypt,
    }])

    assert Doorman.authenticate(@valid_email, "password")
  end

  test "authenticate/2 takes invalid email and valid password and returns true" do
    Mix.Config.persist([doorman: %{
       repo: FakeSuccessRepo,
       user_module: Fake,
       secure_with: Doorman.Auth.Bcrypt,
    }])

    refute Doorman.authenticate("fake", "password")
  end

  test "authenticate/2 takes valid email and invalid password and returns true" do
    Mix.Config.persist([doorman: %{
       repo: FakeSuccessRepo,
       user_module: Fake,
       secure_with: Doorman.Auth.Bcrypt,
    }])

    refute Doorman.authenticate(@valid_email, "wrong")
  end
end
