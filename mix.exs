defmodule UeberauthGitlab.Mixfile do
  use Mix.Project

  @version "0.4.0"
  @source_url "https://github.com/mtchavez/ueberauth_gitlab"

  def project do
    [
      app: :ueberauth_gitlab_strategy,
      version: @version,
      package: package(),
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: @source_url,
      homepage_url: @source_url,
      description: description(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ueberauth, :oauth2]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oauth2, "~> 2.0"},
      {:ueberauth, "~> 0.7.0"},

      # dev/test only dependencies
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.13", only: :test, runtime: false},

      # docs dependencies
      {:earmark, ">= 1.4.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.22.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end

  defp description do
    "An Ueberauth strategy for using Gitlab to authenticate your users."
  end

  defp package do
    [
      name: "ueberauth_gitlab_strategy",
      files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG.*"],
      maintainers: ["Chavez"],
      licenses: ["MIT"],
      links: %{
        Changelog: "#{@source_url}/blob/master/CHANGELOG.md",
        GitHub: @source_url
      }
    ]
  end
end
