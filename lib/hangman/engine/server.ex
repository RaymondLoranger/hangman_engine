defmodule Hangman.Engine.Server do
  @moduledoc """
  Implements a _Hangman Game_ server.
  """

  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__
  alias Hangman.Engine.Game

  require Logger

  @typep from :: GenServer.from()

  @ets Application.get_env(@app, :ets_name)
  @phrase "saving..."
  # @reg Application.get_env(@app, :registry)

  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(game_name),
    do: GenServer.start_link(Server, game_name, name: via(game_name))

  # @spec via(String.t) :: {:via, module, {atom, tuple}}
  # def via(game_name), do: {:via, Registry, {@reg , key(game_name)}}

  @spec via(String.t()) :: {:global, tuple}
  def via(game_name), do: {:global, key(game_name)}

  ## Private functions

  @spec key(String.t()) :: tuple
  defp key(game_name), do: {Server, game_name}

  @spec save(Game.t()) :: Game.t()
  defp save(game) do
    game |> text() |> Logger.info()
    true = :ets.insert(@ets, {key(game.game_name), game})
    game
  end

  @spec text(Game.t(), String.t()) :: String.t()
  defp text(game, phrase \\ @phrase) do
    """
    \n#{game.game_name |> key() |> inspect()} #{self() |> inspect()}
    #{phrase}
    #{inspect(game, pretty: true)}
    """
  end

  @spec game(String.t()) :: Game.t()
  defp game(game_name) do
    case :ets.lookup(@ets, key(game_name)) do
      [] -> game_name |> Game.new_game() |> save()
      [{_key, game}] -> game
    end
  end

  ## Callbacks

  @spec init(String.t()) :: {:ok, Game.t()}
  def init(game_name), do: {:ok, game(game_name)}

  @spec handle_call(term, from, Game.t()) :: {:reply, Game.tally(), Game.t()}
  def handle_call({:make_move, guess}, _from, game) do
    game = Game.make_move(game, guess) |> save()
    {:reply, Game.tally(game), game}
  end

  def handle_call(:tally, _from, game), do: {:reply, Game.tally(game), game}

  @spec terminate(term, Game.t()) :: true
  def terminate(:shutdown = reason, game) do
    game
    |> text("terminating with reason #{inspect(reason)}...")
    |> Logger.info()

    true = :ets.delete(@ets, key(game.game_name))
  end

  def terminate(reason, game) do
    game
    |> text("terminating with reason #{inspect(reason)}...")
    |> Logger.error()

    true = :ets.delete(@ets, key(game.game.name))
  end
end
