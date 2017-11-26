defmodule Hangman.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :hangman,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      mod: {Hangman.App, :ok},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:mix_tasks, path: "../mix_tasks", only: :dev, runtime: false},
      {:persist_config, "~> 0.1"},
      {:dictionary, path: "../dictionary"},
      {:logger_file_backend, "~> 0.0.9"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
