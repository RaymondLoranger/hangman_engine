defmodule Hangman.Engine.GameRecovery do
  @moduledoc false

  use GenServer
  use PersistConfig

  alias __MODULE__
  alias Hangman.Engine.{GameServer, GameSup}

  @ets get_env(:ets_name)

  @spec start_link(term) :: GenServer.on_start()
  def start_link(:ok),
    do: GenServer.start_link(GameRecovery, :ok, name: GameRecovery)

  ## Private functions

  @spec restart_servers :: :ok
  defp restart_servers do
    @ets
    |> :ets.match_object({{GameServer, :_}, :_})
    |> Enum.each(fn {{GameServer, game_name}, _game} ->
      # Child may already be started...
      DynamicSupervisor.start_child(GameSup, {GameServer, game_name})
    end)
  end

  ## Callbacks

  @spec init(term) :: {:ok, :ok}
  def init(:ok), do: {:ok, restart_servers()}
end
