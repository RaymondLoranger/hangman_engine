defmodule Hangman.Engine.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hangman_engine,
      version: "0.1.10",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Hangman.Engine.TopSup, :ok}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_tasks,
       github: "RaymondLoranger/mix_tasks", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:persist_config, "~> 0.4", runtime: false},
      {:logger_file_backend, "~> 0.0.9"},
      {:hangman_dictionary, github: "RaymondLoranger/hangman_dictionary"}
    ]
  end
end
