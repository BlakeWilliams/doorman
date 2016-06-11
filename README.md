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
  user_module: MyApp.User
```

Next add the `Doorman` plug with the desired strategy. Currently
`Doorman.Strategy.Session` is the only available strategy.

```elixir
plug Doorman, Doorman.Strategy.Session
```

Finally, after authenticating your user call your strategies `login` method.

```elixir
conn |> Doorman.Strategy.Session.login(user) |> redirect(to: "/")
```
