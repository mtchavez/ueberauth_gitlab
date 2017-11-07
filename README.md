# Überauth Gitlab

[![Latest Version](http://img.shields.io/github/release/mtchavez/ueberauth_gitlab.svg?style=flat-square)](https://github.com/mtchavez/ueberauth_gitlab/releases)
[![Build Status](https://travis-ci.org/mtchavez/ueberauth_gitlab.svg?branch=master)](https://travis-ci.org/mtchavez/ueberauth_gitlab)

> Gitlab OAuth2 strategy for Überauth.

## Installation

1. Setup your application in Gitlab under your profile [applications menu][gitlab-apps]

1. Add `:ueberauth_gitlab_strategy` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_gitlab_strategy, "~> 0.1"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_gitlab]]
    end
    ```

1. Add Gitlab to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        gitlab: {Ueberauth.Strategy.Gitlab, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Gitlab.OAuth,
      client_id: System.get_env("GITLAB_CLIENT_ID"),
      client_secret: System.get_env("GITLAB_CLIENT_SECRET")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller

      pipeline :browser do
        plug Ueberauth
        ...
       end
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. You controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example][example-app] application
on how to integrate other strategies. Adding Gitlab should be similar to Github.

## Calling

Depending on the configured url you can initial the request through:

    /auth/gitlab

Or with options:

    /auth/gitlab?scope=api read_user


```elixir
config :ueberauth, Ueberauth,
  providers: [
    gitlab: {
      Ueberauth.Strategy.Gitlab, [
        default_scope: "api read_user read_registry"
      ]
    }
  ]
```

It is also possible to disable the sending of the `redirect_uri` to Gitlab. This
is particularly useful when your production application sits behind a proxy that
handles SSL connections. In this case, the `redirect_uri` sent by `Ueberauth`
will start with `http` instead of `https`, and if you configured your Gitlb OAuth
application's callback URL to use HTTPS, Gitlab will throw an `uri_missmatch` error. In addition if the `redirect_uri` on the the authorize request **must match**
the `redirect_uri` on the token request.


## Documentation

The docs can be found at [ueberauth_gitlab][package-docs] on [Hex Docs][hex-docs].

[example-app]: https://github.com/ueberauth/ueberauth_example
[gitlab-apps]: https://gitlab.com/profile/applications
[hex-docs]: https://hexdocs.pm
[package-docs]: https://hexdocs.pm/ueberauth_gitlab_strategy
