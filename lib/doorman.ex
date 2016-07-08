defmodule Doorman do
  @moduledoc """
  Provides authentication helpers that take advantage of the options configured
  in your config files.
  """

  @doc """
  Authenticates a user by their email and password. Returns the user if the
  user is found and the password is correct, otherwise nil.

  Requires `user_module`, `secure_with`, and `repo` to be configured via
  `Mix.Config`. See [README.md] for an example.

  ```
  Doorman.authenticate("joe@dirt.com", "brandyr00lz")
  ```
  """
  def authenticate(email, password) do
    user = repo_module.get_by(user_module, email: email)
    if user && authenticate_user(user, password) do
      user
    else
      nil
    end
  end

  @doc """
  Authenticates a user. Returns true if the user's password and the given
  password match based on the strategy configured, otherwise false.

  Use `authenticate/2` if if you would to authenticate by email and password.

  Requires `user_module`, `secure_with`, and `repo` to be configured via
  `Mix.Config`. See [README.md] for an example.

  ```
  user = Myapp.Repo.get(Myapp.User, 1)
  Doorman.authenticate_user(user, "brandyr00lz")
  ```
  """
  def authenticate_user(user, password) do
    auth_module.authenticate(user, password)
  end

  @doc """
  Returns true if passed in `conn`s `assigns` has a non-nil `:current_user`,
  otherwise returns false.

  Make sure your pipeline uses a login plug to fetch the current user for this
  function to work correctly..
  """
  def logged_in?(conn) do
    conn.assigns[:current_user] != nil
  end

  defp repo_module do
    get_module(:repo)
  end

  defp user_module do
    get_module(:user_module)
  end

  defp auth_module do
    get_module(:secure_with)
  end

  defp get_module(name) do
    case Application.get_env(:doorman, name) do
      nil ->
        raise """
        You must add `#{Atom.to_string(name)}` to `doorman` in your config

        Here is an example configuration:

          config :doorman,
            repo: MyApp.Repo,
            secure_with: Doorman.Auth.Bcrypt,
            user_module: MyApp.User
        """
      module -> module
    end
  end
end
