defmodule Hangman do
  @moduledoc """
  Models a Hangman game.
  """

  alias Hangman.{Game, Server}

  @doc """
  Starts a new game.

  ## Examples

      iex> Hangman.new_game("Meg")
      "Meg"
  """
  @spec new_game(String.t) :: String.t
  def new_game(player) do
    {:ok, _pid} = Supervisor.start_child(Hangman.Sup, [player])
    player
  end

  @doc """
  Ends a game.

  ## Examples

      iex> Hangman.new_game("Ben")
      iex> Hangman.end_game("Ben")
      :ok
  """
  @spec end_game(String.t) :: :ok
  def end_game(player) do
    player
    |> Server.via()
    |> GenServer.stop(:shutdown)
  end

  @doc """
  Returns the tally of a game.

  ## Examples

      iex> Hangman.new_game("Jim")
      iex> tally = Hangman.tally("Jim")
      iex> %{
      ...>   game_state: :initializing,
      ...>   turns_left: 7,
      ...>   letters: letters
      ...> } = tally
      iex> all_underscores? = Enum.all?(letters, & &1 == "_")
      iex> is_list(letters) and all_underscores?
      true
  """
  @spec tally(String.t) :: Game.tally
  def tally(player) do
    player
    |> Server.via()
    |> GenServer.call(:tally)
  end

  @doc """
  Makes a move and returns the tally.

  ## Examples

      iex> Hangman.new_game("Ed")
      iex> Hangman.make_move("Ed", "a").game_state in [:good_guess, :bad_guess]
      true
  """
  @spec make_move(String.t, String.codepoint) :: Game.tally
  def make_move(player, guess) do
    player
    |> Server.via()
    |> GenServer.call({:make_move, guess})
  end
end
