defmodule Hangman.Engine.TopSup do
  use Application
  use PersistConfig

  alias __MODULE__
  alias Hangman.Engine.{GameRecovery, DynGameSup}

  @ets get_env(:ets_name)
  # @reg get_env(:registry)

  # @impl Application
  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, :ok = _start_args) do
    case :ets.whereis(@ets) do
      :undefined -> :ets.new(@ets, [:public, :named_table])
      ets_reference -> ets_reference
    end

    [
      # {Registry, keys: :unique, name: @reg},

      # Child spec relying on `use DynamicSupervisor`...
      {DynGameSup, :ok},

      # Child spec relying on `use GenServer`...
      {GameRecovery, :ok}
    ]
    # NOTE: Strategy...                              ↓ ↓ ↓ ↓ ↓ ↓ ↓
    |> Supervisor.start_link(name: TopSup, strategy: :rest_for_one)
  end
end
