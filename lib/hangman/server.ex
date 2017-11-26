defmodule Hangman.Server do
  # @moduledoc """
  # Implements a Hangman game server.
  # """
  @moduledoc false

  use GenServer, restart: :transient
  use PersistConfig

  alias Hangman.Game

  require Logger

  @typep from :: GenServer.from
  @typep meta_key :: Registry.meta_key

  @me __MODULE__
  @reg Application.get_env(@app, :registry)

  @spec start_link(term, String.t) :: GenServer.on_start
  def start_link(:ok, player) do
    GenServer.start_link(@me, player, name: via(player))
  end

  @spec via(String.t) :: {:via, module, {atom, meta_key}}
  def via(player), do: {:via, Registry, {@reg , meta_key(player)}}

  ## Private functions

  @spec meta_key(String.t) :: meta_key
  defp meta_key(player), do: {@me, player}

  @spec game(String.t) :: Game.t
  defp game(player) do
    case Registry.meta(@reg, meta_key(player)) do
      :error -> Game.new_game(player) # => create
      {:ok, game} ->
        info(game, "restored") |> Logger.info()
        game # => restore
    end
  end

  @spec save(Game.t) :: Game.t
  defp save(game) do
    info(game, "saving") |> Logger.info()
    Registry.put_meta(@reg, meta_key(game.player), game)
    game
  end

  @spec info(Game.t, String.t) :: String.t
  defp info(game, phrase) do
    meta_key = game.player |> meta_key() |> inspect
    self = self() |> inspect()
    game = inspect(game)
    "#{meta_key} #{self} #{phrase} #{game}"
  end

  ## Callbacks

  @spec init(String.t) :: {:ok, Game.t}
  def init(player), do: {:ok, game(player)}

  @spec handle_call(term, from, Game.t) :: {:reply, Game.tally, Game.t}
  def handle_call({:make_move, guess}, _from, game) do
    game = game |> Game.make_move(guess) |> save()
    {:reply, Game.tally(game), game}
  end
  def handle_call(:tally, _from, game), do: {:reply, Game.tally(game), game}
end
