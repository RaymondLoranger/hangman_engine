defmodule Hangman.Engine.Recover do
  use GenServer
  use PersistConfig

  alias __MODULE__
  alias Hangman.Engine.{Server, Sup}

  @ets Application.get_env(@app, :ets_name)

  @spec start_link(term) :: GenServer.on_start()
  def start_link(:ok), do: GenServer.start_link(Recover, :ok, name: Recover)

  ## Private functions

  @spec restart_servers() :: :ok
  defp restart_servers() do
    @ets
    |> :ets.match_object({{Server, :_}, :_})
    |> Enum.each(fn {{Server, game_name}, _game} ->
      # Child may already be started...
      DynamicSupervisor.start_child(Sup, {Server, game_name})
    end)
  end

  ## Callbacks

  @spec init(term) :: {:ok, :ok}
  def init(:ok), do: {:ok, restart_servers()}
end
