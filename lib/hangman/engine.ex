# ┌──────────────────────────────────────────────────────────────┐
# │ Based on the course "Elixir for Programmers" by Dave Thomas. │
# └──────────────────────────────────────────────────────────────┘
defmodule Hangman.Engine do
  use PersistConfig

  @course_ref Application.get_env(@app, :course_ref)

  @moduledoc """
  Models a Hangman game.

  ##### #{@course_ref}
  """

  alias __MODULE__.{Game, Server, Sup}

  @doc """
  Starts a new game.

  ## Examples

      iex> alias Hangman.Engine
      iex> {:ok, game_id} = Engine.new_game("Meg")
      iex> {:error, {:already_started, ^game_id}} = Engine.new_game("Meg")
      iex> is_pid(game_id)
      true
  """
  @spec new_game(String.t()) :: Supervisor.on_start_child()
  def new_game(player) when is_binary(player) do
    DynamicSupervisor.start_child(Sup, {Server, player})
  end

  @doc """
  Ends a game.

  ## Examples

      iex> alias Hangman.Engine
      iex> Engine.new_game("Ben")
      iex> Engine.end_game("Ben")
      :ok
  """
  @spec end_game(String.t()) :: :ok
  def end_game(player) when is_binary(player) do
    player |> Server.via() |> GenServer.stop(:shutdown)
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
  @spec tally(String.t()) :: Game.tally()
  def tally(player) when is_binary(player) do
    player |> Server.via() |> GenServer.call(:tally)
  end

  @doc """
  Makes a move and returns the tally.

  ## Examples

      iex> alias Hangman.Engine
      iex> Engine.new_game("Ed")
      iex> Engine.make_move("Ed", "a").game_state in [:good_guess, :bad_guess]
      true
  """
  @spec make_move(String.t(), String.codepoint()) :: Game.tally()
  def make_move(player, guess) when is_binary(player) and is_binary(guess) do
    player |> Server.via() |> GenServer.call({:make_move, guess})
  end
end
