# ┌──────────────────────────────────────────────────────────────┐
# │ Based on the course "Elixir for Programmers" by Dave Thomas. │
# └──────────────────────────────────────────────────────────────┘
defmodule Hangman.Engine do
  @moduledoc """
  Models the _Hangman Game_.

  ##### Based on the course [Elixir for Programmers](https://codestool.coding-gnome.com/courses/elixir-for-programmers) by Dave Thomas.
  """

  alias __MODULE__.{DynGameSup, Game, GameServer}

  @doc """
  Starts a new game server process and supervises it.

  ## Examples

      iex> alias Hangman.Engine
      iex> {:ok, game_id} = Engine.new_game("Meg")
      iex> {:error, {:already_started, ^game_id}} = Engine.new_game("Meg")
      iex> is_pid(game_id)
      true
  """
  @spec new_game(Game.name()) :: Supervisor.on_start_child()
  def new_game(game_name) when is_binary(game_name) do
    DynamicSupervisor.start_child(DynGameSup, {GameServer, game_name})
  end

  @doc """
  Stops a game server process normally. It won't be restarted.

  ## Examples

      iex> alias Hangman.Engine
      iex> Engine.new_game("Ben")
      iex> Engine.end_game("Ben")
      :ok
  """
  @spec end_game(Game.name()) :: :ok
  def end_game(game_name) when is_binary(game_name) do
    GameServer.via(game_name) |> GenServer.stop(:shutdown)
  end

  @doc """
  Returns the tally of a game.

  ## Examples

      iex> alias Hangman.Engine
      iex> Engine.new_game("Jim")
      iex> tally = Engine.tally("Jim")
      iex> %{
      ...>   game_state: :initializing,
      ...>   turns_left: 7,
      ...>   letters: letters
      ...> } = tally
      iex> all_underscores? = Enum.all?(letters, & &1 == "_")
      iex> is_list(letters) and all_underscores?
      true
  """
  @spec tally(Game.name()) :: Game.tally()
  def tally(game_name) when is_binary(game_name) do
    GameServer.via(game_name) |> GenServer.call(:tally)
  end

  @doc """
  Guesses the word of a game.

  ## Examples

      iex> alias Hangman.Engine
      iex> Engine.new_game("Joe")
      iex> tally = Engine.guess_word("Joe")
      iex> %{
      ...>   game_state: :initializing,
      ...>   turns_left: 7,
      ...>   letters: letters
      ...> } = tally
      iex> no_underscores? = Enum.all?(letters, & &1 != "_")
      iex> all_lowercase? = Enum.join(letters) |> String.match?(~r/[a-z]+/)
      iex> is_list(letters) and no_underscores? and all_lowercase?
      true
  """
  @spec guess_word(Game.name()) :: Game.tally()
  def guess_word(game_name) when is_binary(game_name) do
    GameServer.via(game_name) |> GenServer.call(:guess_word)
  end

  @doc """
  Lets a player suggest a guess letter.

  ## Examples

      iex> alias Hangman.Engine
      iex> Engine.new_game("Ed")
      iex> Engine.make_move("Ed", "a").game_state in [:good_guess, :bad_guess]
      true
  """
  @spec make_move(Game.name(), String.codepoint()) :: Game.tally()
  def make_move(game_name, guess)
      when is_binary(game_name) and is_binary(guess) do
    GameServer.via(game_name) |> GenServer.call({:make_move, guess})
  end

  @doc """
  Generates a random game name.
  """
  defdelegate random_game_name, to: Game, as: :random_name
end
