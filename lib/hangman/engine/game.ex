defmodule Hangman.Engine.Game do
  # @moduledoc """
  # Implements a Hangman game.
  # """
  @moduledoc false

  alias __MODULE__
  alias Hangman.Dictionary

  @enforce_keys [:player_name, :letters]
  defstruct player_name: "",
            turns_left: 7,
            game_state: :initializing,
            letters: [],
            used: MapSet.new()

  @type state ::
          :initializing
          | :good_gess
          | :bad_guess
          | :already_used
          | :lost
          | :won
  @type t :: %Game{
          player_name: String.t(),
          turns_left: non_neg_integer,
          game_state: state,
          letters: [String.codepoint()],
          used: MapSet.t(String.codepoint())
        }
  @type tally :: map

  @doc """
  Returns a new Hangman game with a `word` to be guessed.

  ## Examples

      iex> alias Hangman.Engine.Game
      iex> Game.new_game("Mr. Smith").game_state
      :initializing
  """
  @spec new_game(String.t(), String.t()) :: t
  def new_game(player_name, word \\ Dictionary.random_word()) do
    %Game{player_name: player_name, letters: String.codepoints(word)}
  end

  @spec make_move(t, String.codepoint()) :: t
  def make_move(%Game{game_state: state} = game, _guess)
      when state in [:won, :lost],
      do: game

  # Guess not validated here; should be done in client interface...
  def make_move(%Game{} = game, guess) do
    accept_move(game, guess, MapSet.member?(game.used, guess))
  end

  @spec tally(t) :: tally
  def tally(%Game{} = game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: reveal_guessed(game.letters, game.used)
    }
  end

  ## Private functions

  @spec reveal_guessed([String.codepoint()], MapSet.t()) :: [String.codepoint()]
  defp reveal_guessed(letters, used) do
    letters |> Enum.map(&if MapSet.member?(used, &1), do: &1, else: "_")
  end

  @spec accept_move(t, String.codepoint(), boolean) :: t
  defp accept_move(game, _guess, _already_guessed = true) do
    struct(game, game_state: :already_used)
  end

  defp accept_move(game, guess, _never_guessed) do
    game.used
    |> update_in(&MapSet.put(&1, guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end

  @spec score_guess(t, boolean) :: t
  defp score_guess(game, _good_guess = true) do
    state =
      game.letters
      |> MapSet.new()
      |> MapSet.subset?(game.used)
      |> if(do: :won, else: :good_guess)

    struct(game, game_state: state)
  end

  defp score_guess(%Game{turns_left: 1} = game, _bad_guess) do
    struct(game, game_state: :lost, turns_left: 0)
  end

  defp score_guess(%Game{turns_left: 0} = game, _bad_guess), do: game

  defp score_guess(%Game{turns_left: turns_left} = game, _bad_guess) do
    struct(game, game_state: :bad_guess, turns_left: turns_left - 1)
  end
end
