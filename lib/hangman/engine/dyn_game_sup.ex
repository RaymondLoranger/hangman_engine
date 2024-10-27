defmodule Hangman.Engine.DynGameSup do
  @moduledoc """
  A supervisor that starts game server processes dynamically.
  """

  use DynamicSupervisor

  alias __MODULE__

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(_arg = :ok),
    do: DynamicSupervisor.start_link(DynGameSup, :ok, name: DynGameSup)

  ## Callbacks

  @spec init(term) :: {:ok, DynamicSupervisor.sup_flags()} | :ignore
  def init(_arg = :ok), do: DynamicSupervisor.init(strategy: :one_for_one)
end
