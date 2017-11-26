defmodule Hangman.App do
  @moduledoc false

  use Application
  use PersistConfig

  @me __MODULE__
  @reg Application.get_env(@app, :registry)

  @spec start(Application.start_type, term) :: {:ok, pid}
  def start(_type, :ok) do
    [
      {Registry, keys: :unique, name: @reg},
      {Hangman.Sup, :ok} # child spec relying on use Supervisor...
    ]
    |> Supervisor.start_link(name: @me, strategy: :rest_for_one)
  end
end
