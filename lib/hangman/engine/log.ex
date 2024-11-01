defmodule Hangman.Engine.Log do
  use File.Only.Logger

  alias Hangman.Engine.GameServer

  error :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Server: #{GameServer.via(game.game_name) |> inspect() |> maybe_break(10)}
    • Server PID: #{self() |> inspect()}
    • Reason: #{inspect(reason) |> maybe_break(10)}
    • Game being terminated: #{inspect(game) |> maybe_break(25)}
    #{from(env, __MODULE__)}\
    """
  end

  info :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Server: #{GameServer.via(game.game_name) |> inspect() |> maybe_break(10)}
    • Server PID: #{self() |> inspect()}
    • Reason: #{inspect(reason) |> maybe_break(10)}
    • Game being terminated: #{inspect(game) |> maybe_break(25)}
    #{from(env, __MODULE__)}\
    """
  end

  info :save, {game, request, env} do
    """
    \nSaving game...
    • Server: #{GameServer.via(game.game_name) |> inspect() |> maybe_break(10)}
    • Server PID: #{self() |> inspect()}
    • Request: #{inspect(request) |> maybe_break(11)}
    • Game being saved: #{inspect(game) |> maybe_break(20)}
    #{from(env, __MODULE__)}\
    """
  end

  info :spawned, {game_name, env} do
    """
    \nSpawned game server process...
    • Game name: #{game_name}
    • Server PID: #{self() |> inspect()}
    #{from(env, __MODULE__)}\
    """
  end

  info :restarted, {game, env} do
    """
    \nRestarted game server process...
    • Server: #{GameServer.via(game.game_name) |> inspect() |> maybe_break(10)}
    • Server PID: #{self() |> inspect()}
    • Game being restarted: #{inspect(game) |> maybe_break(24)}
    #{from(env, __MODULE__)}\
    """
  end

  info :timeout, {timeout, game, env} do
    """
    \nGame server process timed out...
    • Game name: #{game.game_name}
    • Timeout: #{round(timeout / 1000 / 60)} min
    • Server PID: #{self() |> inspect()}
    #{from(env, __MODULE__)}\
    """
  end
end
