defmodule Hangman.Engine.GameTest do
  use ExUnit.Case, async: true

  alias Hangman.Engine.Game

  doctest Game

  setup_all do
    games = %{
      random: Game.new("Rand"),
      wibble: Game.new("Will", "wibble")
    }

    moves = %{
      winning: [
        {"w", :good_guess, 7},
        {"i", :good_guess, 7},
        {"b", :good_guess, 7},
        {"l", :good_guess, 7},
        {"e", :won, 7}
      ],
      losing: [
        {"m", :bad_guess, 6},
        {"n", :bad_guess, 5},
        {"o", :bad_guess, 4},
        {"p", :bad_guess, 3},
        {"q", :bad_guess, 2},
        {"r", :bad_guess, 1},
        {"s", :lost, 0}
      ],
      tester: fn moves, game ->
        Enum.reduce(moves, game, fn {guess, state, turns_left}, game ->
          game = Game.make_move(game, guess)
          assert game.game_state == state
          assert game.turns_left == turns_left
          game
        end)
      end
    }

    {:ok, games: games, moves: moves}
  end

  describe "Game.new/1" do
    test "returns struct", %{games: games} do
      assert games.random.turns_left == 7
      assert games.random.game_state == :initializing
      assert length(games.random.letters) > 0
      assert Enum.all?(games.random.letters, &(&1 =~ ~r/[a-z]/))
    end
  end

  describe "Game.new/2" do
    test "returns struct", %{games: games} do
      assert games.wibble.turns_left == 7
      assert games.wibble.game_state == :initializing
      assert games.wibble.letters == ~w[w i b b l e]
    end
  end

  describe "Game.make_move/2" do
    test "game static once :won or :lost", %{games: games} do
      for state <- [:won, :lost] do
        game = struct(games.random, game_state: state)
        assert ^game = Game.make_move(game, "x")
      end
    end

    test "first guess of letter: not already used", %{games: games} do
      game = Game.make_move(games.random, "x")
      refute game.game_state == :already_used
    end

    test "second guess of letter: already used", %{games: games} do
      game = Game.make_move(games.random, "x")
      refute game.game_state == :already_used
      game = Game.make_move(game, "x")
      assert game.game_state == :already_used
    end

    test "a good guess is recognized", %{games: games} do
      game = Game.make_move(games.wibble, "w")
      assert game.game_state == :good_guess
      assert game.turns_left == 7
    end

    test "a bad guess is recognized", %{games: games} do
      game = Game.make_move(games.wibble, "x")
      assert game.game_state == :bad_guess
      assert game.turns_left == 6
    end

    test "a guessed word is a won game", %{games: games, moves: moves} do
      moves.tester.(moves.winning, games.wibble)
    end

    test "a lost game is recognized", %{games: games, moves: moves} do
      moves.tester.(moves.losing, games.wibble)
    end
  end
end
