defmodule Hangman.Engine.Log do
  use File.Only.Logger

  alias Hangman.Engine.GameServer

  error :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Inside function:
      #{fun(env)}
    • Server:
      #{GameServer.via(game.game_name) |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'terminate' reason: #{inspect(reason)}
    • Game being terminated:
      #{inspect(game)}
    #{from()}
    """
  end

  info :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Inside function:
      #{fun(env)}
    • Server:
      #{GameServer.via(game.game_name) |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'terminate' reason: #{inspect(reason)}
    • Game being terminated:
      #{inspect(game)}
    #{from()}
    """
  end

  info :save, {game, request, env} do
    """
    \nSaving game...
    • Inside function:
      #{fun(env)}
    • Server:
      #{GameServer.via(game.game_name) |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'handle_call' request:
      #{inspect(request)}
    • Game being saved:
      #{inspect(game)}
    #{from()}
    """
  end

  info :spawned, {game_name} do
    """
    \nSpawned game server process...
    • Game name: #{game_name}
    • Server PID: #{self() |> inspect()}
    #{from()}
    """
  end

  info :restarted, {game_name} do
    """
    \nRestarted game server process...
    • Game name: #{game_name}
    • Server PID: #{self() |> inspect()}
    #{from()}
    """
  end
end
