defmodule Hangman.Engine.GameRecovery do
  @moduledoc """
  Makes processes under the top supervisor fault-tolerant. If any crashes (or
  is killed), it is immediately restarted and the system remains undisturbed.
  """

  use GenServer
  use PersistConfig

  alias __MODULE__
  alias Hangman.Engine.{DynGameSup, GameServer}

  @ets get_env(:ets_name)

  @spec start_link(term) :: GenServer.on_start()
  def start_link(:ok = _init_arg),
    do: GenServer.start_link(GameRecovery, :ok, name: GameRecovery)

  ## Private functions

  @spec restart_servers :: :ok
  defp restart_servers do
    @ets
    |> :ets.match_object({{GameServer, :_}, :_})
    |> Enum.each(fn {{GameServer, game_name}, _game} ->
      # Child may already be started...
      DynamicSupervisor.start_child(DynGameSup, {GameServer, game_name})
    end)
  end

  ## Callbacks

  @spec init(term) :: {:ok, term}
  def init(:ok = _init_arg), do: {:ok, restart_servers()}
end
