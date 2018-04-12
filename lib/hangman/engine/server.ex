defmodule Hangman.Engine.Server do
  # @moduledoc """
  # Implements a Hangman game server.
  # """
  @moduledoc false

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
  def start_link(player) do
    GenServer.start_link(Server, player, name: via(player))
  end

  # @spec via(String.t) :: {:via, module, {atom, tuple}}
  # def via(player), do: {:via, Registry, {@reg , key(player)}}

  @spec via(String.t()) :: {:global, tuple}
  def via(player), do: {:global, key(player)}

  ## Private functions

  @spec key(String.t()) :: tuple
  defp key(player), do: {Server, player}

  @spec save(Game.t()) :: Game.t()
  defp save(game) do
    game |> text(@phrase) |> Logger.info()
    true = :ets.insert(@ets, {key(game.player), game})
    game
  end

  @spec text(Game.t(), String.t()) :: String.t()
  defp text(game, phrase) do
    key = game.player |> key() |> inspect()
    self = self() |> inspect()
    game = inspect(game, pretty: true)
    "\n#{key} #{self}\n#{phrase}\n#{game}\n"
  end

  @spec game(String.t()) :: Game.t()
  defp game(player) do
    case :ets.lookup(@ets, key(player)) do
      [] -> Game.new_game(player) |> save()
      [{_key, game}] -> game
    end
  end

  ## Callbacks

  @spec init(String.t()) :: {:ok, Game.t()}
  def init(player), do: {:ok, game(player)}

  @spec handle_call(term, from, Game.t()) :: {:reply, Game.tally(), Game.t()}
  def handle_call({:make_move, guess}, _from, game) do
    game = Game.make_move(game, guess) |> save()
    {:reply, Game.tally(game), game}
  end

  def handle_call(:tally, _from, game), do: {:reply, Game.tally(game), game}

  @spec terminate(term, Game.t()) :: true
  def terminate(:shutdown, game), do: true = :ets.delete(@ets, key(game.player))
end
