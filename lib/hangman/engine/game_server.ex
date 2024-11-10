defmodule Hangman.Engine.GameServer do
  @moduledoc """
  A server process that holds a game struct as its state.
  Times out after 30 minutes of inactivity.
  """

  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__
  alias Hangman.Engine.Log
  alias Hangman.{Dictionary, Game}

  @ets get_env(:ets_name)
  # @reg get_env(:registry)
  @timeout :timer.minutes(30)
  # @wait 100

  @doc """
  Spawns a game server process to be registered via `game_name`.
  """
  @spec start_link(Game.name()) :: GenServer.on_start()
  def start_link(game_name),
    do: GenServer.start_link(GameServer, game_name, name: via(game_name))

  # @spec via(Game.name()) :: {:via, Registry, tuple}
  # def via(game_name), do: {:via, Registry, {@reg , key(game_name)}}

  @doc """
  Allows to register or look up a game server process via `game_name`.
  """
  @spec via(Game.name()) :: {:global, tuple}
  def via(game_name), do: {:global, key(game_name)}

  ## Private functions

  @spec key(Game.name()) :: tuple
  defp key(game_name), do: {GameServer, game_name}

  @spec save(Game.t(), term) :: Game.t()
  defp save(game, request) do
    :ok = Log.info(:save, {game, request, __ENV__})
    true = :ets.insert(@ets, {key(game.game_name), game})
    game
  end

  ## Callbacks

  @spec init(Game.name()) :: {:ok, Game.t(), timeout}
  def init(game_name) do
    game =
      case :ets.lookup(@ets, key(game_name)) do
        [] ->
          :ok = Log.info(:spawned, {game_name, __ENV__})
          Dictionary.random_word() |> Game.new(game_name) |> save(nil)

        [{_key, game}] ->
          :ok = Log.info(:restarted, {game, __ENV__})
          game
      end

    {:ok, game, @timeout}
  end

  @spec handle_call(request :: term, GenServer.from(), Game.t()) ::
          {:reply, Game.tally(), Game.t(), timeout}
  def handle_call({:make_move, guess} = request, _from, game) do
    game = Game.make_move(game, guess) |> save(request)
    {:reply, Game.tally(game), game, @timeout}
  end

  def handle_call(:resign = request, _from, game) do
    game = Game.resign(game) |> save(request)
    {:reply, Game.tally(game), game, @timeout}
  end

  def handle_call(:tally, _from, game),
    do: {:reply, Game.tally(game), game, @timeout}

  @spec handle_info(msg :: :timeout | term, Game.t()) ::
          {:stop, reason :: tuple, Game.t()} | {:noreply, Game.t()}
  def handle_info(:timeout, game) do
    :ok = Log.info(:timeout, {@timeout, game, __ENV__})
    {:stop, {:shutdown, :timeout}, game}
  end

  def handle_info(_message, game), do: {:noreply, game}

  @spec terminate(term, Game.t()) :: true
  def terminate(reason, game)
      when reason in [:shutdown, {:shutdown, :timeout}] do
    :ok = Log.info(:terminate, {reason, game, __ENV__})
    true = :ets.delete(@ets, key(game.game_name))
    # Ensure message logged before exiting...
    # Process.sleep(@wait)
  end

  def terminate(reason, game) do
    :ok = Log.error(:terminate, {reason, game, __ENV__})
    true = :ets.delete(@ets, key(game.game_name))
    # Ensure message logged before exiting...
    # Process.sleep(@wait)
  end
end
