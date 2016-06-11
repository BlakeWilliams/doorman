# Doorman

Simple tools to make authentication in Plug/Phoenix based applications easier
without bloat.

## Installation

Add doorman to your dependencies in `mix.exs`.

```
def deps do
  [{:doorman, "~> 0.0.1"}]
end
```

## Usage

To get started add the following config to `config/config.exs`.


```elixir
config :doorman,
  repo: MyApp.Repo,
  user_module: MyApp.User,
  login_strategy: Doorman.Login.Session
```

Next add the `Doorman` plug which assigns `current_user` on `conn`.

```elixir
plug Doorman, Doorman.Strategy.Session
```

Finally, after authenticating your user call the `Doorman.login/2` method in
your conn pipeline also passing the user.


```elixir
conn |> Doorman.login(user) |> redirect(to: "/")
```
