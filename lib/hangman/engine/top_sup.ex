defmodule Hangman.Engine.TopSup do
  use Application
  use PersistConfig

  alias __MODULE__
  alias Hangman.Engine.{GameRecovery, GameSup}

  @ets Application.get_env(@app, :ets_name)
  # @reg Application.get_env(@app, :registry)

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_type, :ok) do
    :ets.new(@ets, [:public, :named_table])

    [
      # {Registry, keys: :unique, name: @reg},

      # Child spec relying on use DynamicSupervisor...
      {GameSup, :ok},

      # Child spec relying on use GenServer...
      {GameRecovery, :ok}
    ]
    |> Supervisor.start_link(name: TopSup, strategy: :rest_for_one)
  end
end
