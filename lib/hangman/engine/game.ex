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
          letters: [String.codepoint()],
          used: used
        }
  @type tally :: %{
          game_state: state,
          turns_left: turns_left,
          letters: [String.codepoint()],
          guesses: [String.codepoint()]
        }
  @type turns_left :: non_neg_integer
  @type used :: MapSet.t(String.codepoint())

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

  @spec make_move(t, String.codepoint()) :: t
  def make_move(%Game{game_state: state} = game, _guess)
      when state in [:won, :lost],
      do: game

  # Guess not validated here; should be done in client interface...
  def make_move(%Game{} = game, guess) do
    accept_move(game, guess, MapSet.member?(game.used, guess))
  end

  @spec guess_word(t) :: t
  def guess_word(%Game{letters: letters, used: used} = game) do
    %Game{game | used: MapSet.union(used, MapSet.new(letters))}
  end

  @spec tally(t) :: tally
  def tally(%Game{} = game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: reveal_guessed(game.letters, game.used),
      guesses: MapSet.to_list(game.used)
    }
  end

  ## Private functions

  @spec reveal_guessed([String.codepoint()], used) :: [String.codepoint()]
  defp reveal_guessed(letters, used) do
    letters |> Enum.map(&if MapSet.member?(used, &1), do: &1, else: "_")
  end

  @spec accept_move(t, String.codepoint(), boolean) :: t
  defp accept_move(game, _guess, _already_guessed = true) do
    put_in(game.game_state, :already_used)
  end

  defp accept_move(game, guess, _never_guessed) do
    update_in(game.used, &MapSet.put(&1, guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end

  @spec score_guess(t, boolean) :: t
  defp score_guess(game, _good_guess = true) do
    state =
      MapSet.new(game.letters)
      |> MapSet.subset?(game.used)
      |> if(do: :won, else: :good_guess)

    put_in(game.game_state, state)
  end

  defp score_guess(%Game{turns_left: 1} = game, _bad_guess) do
    %Game{game | game_state: :lost, turns_left: 0}
  end

  defp score_guess(%Game{turns_left: 0} = game, _bad_guess), do: game

  defp score_guess(%Game{turns_left: turns_left} = game, _bad_guess) do
    %Game{game | game_state: :bad_guess, turns_left: turns_left - 1}
  end
end
