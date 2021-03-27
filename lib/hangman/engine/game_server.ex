defmodule Hangman.Engine.GameServer do
  @moduledoc """
  A server process that holds a game struct as its state.
  """

  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__
  alias Hangman.Engine.Log
  alias Hangman.Game

  @ets get_env(:ets_name)
  # @reg get_env(:registry)
  @wait 100

  @spec start_link(Game.name()) :: GenServer.on_start()
  def start_link(game_name),
    do: GenServer.start_link(GameServer, game_name, name: via(game_name))

  # @spec via(Game.name()) :: {:via, module, {atom, tuple}}
  # def via(game_name), do: {:via, Registry, {@reg , key(game_name)}}

  @spec via(Game.name()) :: {:global, tuple}
  def via(game_name), do: {:global, key(game_name)}

  ## Private functions

  @spec key(Game.name()) :: tuple
  defp key(game_name), do: {GameServer, game_name}

  @spec game(Game.name()) :: Game.t()
  defp game(game_name) do
    case :ets.lookup(@ets, key(game_name)) do
      [] ->
        :ok = Log.info(:spawned, {game_name})
        Game.new(game_name) |> save(nil)

      [{_key, game}] ->
        :ok = Log.info(:restarted, {game_name})
        game
    end
  end

  @spec save(Game.t(), term) :: Game.t()
  defp save(game, request) do
    :ok = Log.info(:save, {game, request, __ENV__})
    true = :ets.insert(@ets, {key(game.game_name), game})
    game
  end

  ## Callbacks

  @spec init(Game.name()) :: {:ok, Game.t()}
  def init(game_name), do: {:ok, game(game_name)}

  @spec handle_call(request :: term, GenServer.from(), Game.t()) ::
          {:reply, Game.tally(), Game.t()}
  def handle_call({:make_move, guess} = request, _from, game) do
    game = Game.make_move(game, guess) |> save(request)
    {:reply, Game.tally(game), game}
  end

  def handle_call(:tally, _from, game), do: {:reply, Game.tally(game), game}

  @spec terminate(term, Game.t()) :: :ok
  def terminate(:shutdown = reason, game) do
    :ok = Log.info(:terminate, {reason, game, __ENV__})
    true = :ets.delete(@ets, key(game.game_name))
    # Ensure message logged before exiting...
    Process.sleep(@wait)
  end

  def terminate(reason, game) do
    :ok = Log.error(:terminate, {reason, game, __ENV__})
    true = :ets.delete(@ets, key(game.game_name))
    # Ensure message logged before exiting...
    Process.sleep(@wait)
  end
end
