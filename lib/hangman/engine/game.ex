defmodule Hangman.Engine.Game do
  @moduledoc """
  Creates a `game` struct for the _Hangman Game_.
  Also implements the actions of a _Hangman Game_.
  """

  alias __MODULE__
  alias Hangman.Dictionary

  @enforce_keys [:game_name, :letters]
  defstruct game_name: "",
            turns_left: 7,
            game_state: :initializing,
            letters: [],
            used: MapSet.new()

  @type letter :: String.codepoint()
  @type name :: String.t()
  @type state ::
          :initializing
          | :good_guess
          | :bad_guess
          | :already_used
          | :lost
          | :won
  @type t :: %Game{
          game_name: name,
          turns_left: turns_left,
          game_state: state,
          letters: [letter],
          used: used
        }
  @type tally :: %{
          game_state: state,
          turns_left: turns_left,
          letters: [letter | charlist],
          guesses: [letter]
        }
  @type turns_left :: non_neg_integer
  @type used :: MapSet.t(letter)

  @doc """
  Returns a new _Hangman Game_ with a `word` to be guessed.

  ## Examples

      iex> alias Hangman.Engine.Game
      iex> Game.new("Mr. Smith").game_state
      :initializing
  """
  @spec new(name, String.t()) :: t
  def new(game_name, word \\ Dictionary.random_word()) do
    %Game{game_name: game_name, letters: String.codepoints(word)}
  end

  @doc """
  Generates a random name.
  """
  @spec random_name :: name
  def random_name do
    length = Enum.random(4..10)

    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    # Starting at 0 with length "length"...
    |> binary_part(0, length)
  end

  @spec make_move(t, guess :: letter) :: t
  def make_move(%Game{game_state: state} = game, _) when state in [:won, :lost],
    do: game

  # Guess not validated here; should be done in client interface...
  def make_move(%Game{used: used} = game, guess),
    do: accept_move(game, guess, MapSet.member?(used, guess))

  @spec tally(t) :: tally
  def tally(%Game{game_state: game_state, turns_left: turns_left} = game) do
    %{
      game_state: game_state,
      turns_left: turns_left,
      letters: reveal_guessed(game_state, game.letters, game.used),
      guesses: MapSet.to_list(game.used)
    }
  end

  ## Private functions

  @spec reveal_guessed(state, [letter], used) :: [letter | charlist]
  defp reveal_guessed(:lost, letters, used),
    do: letters |> Enum.map(&if MapSet.member?(used, &1), do: &1, else: '#{&1}')

  defp reveal_guessed(_game_state, letters, used),
    do: letters |> Enum.map(&if MapSet.member?(used, &1), do: &1, else: "_")

  @spec accept_move(t, letter, boolean) :: t
  defp accept_move(game, _guess, _already_guessed = true),
    do: put_in(game.game_state, :already_used)

  defp accept_move(game, guess, _never_guessed) do
    update_in(game.used, &MapSet.put(&1, guess))
    |> score_guess(guess in game.letters)
  end

  @spec score_guess(t, boolean) :: t
  defp score_guess(game, _good_guess = true) do
    state =
      if MapSet.new(game.letters) |> MapSet.subset?(game.used),
        do: :won,
        else: :good_guess

    put_in(game.game_state, state)
  end

  defp score_guess(%Game{turns_left: 1} = game, _bad_guess),
    do: %Game{game | game_state: :lost, turns_left: 0}

  defp score_guess(%Game{turns_left: 0} = game, _bad_guess), do: game

  defp score_guess(%Game{turns_left: turns_left} = game, _bad_guess),
    do: %Game{game | game_state: :bad_guess, turns_left: turns_left - 1}
end
