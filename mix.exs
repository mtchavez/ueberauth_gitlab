defmodule UeberauthGitlab.Mixfile do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :ueberauth_gitlab_strategy,
      version: @version,
      package: package(),
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/mtchavez/ueberauth_gitlab",
      homepage_url: "https://github.com/mtchavez/ueberauth_gitlab",
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
      {:ueberauth, "~> 0.4"},

      # dev/test only dependencies
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:exvcr, "~> 0.11.0", only: [:test]},

      # docs dependencies
      {:earmark, ">= 1.4.0", only: :dev},
      {:ex_doc, ">= 0.22.0", only: :dev}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "An Ueberauth strategy for using Gitlab to authenticate your users."
  end

  defp package do
    [
      name: "ueberauth_gitlab_strategy",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Chavez"],
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/mtchavez/ueberauth_gitlab"}
    ]
  end
end
