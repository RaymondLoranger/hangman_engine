defmodule Hangman.Engine.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hangman_engine,
      version: "0.1.9",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Hangman.Engine.Top, :ok}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_tasks,
       github: "RaymondLoranger/mix_tasks", only: :dev, runtime: false},
      {:hangman_dictionary, github: "RaymondLoranger/hangman_dictionary"},
      {:persist_config, "~> 0.1", runtime: false},
      {:logger_file_backend, "~> 0.0.9"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
