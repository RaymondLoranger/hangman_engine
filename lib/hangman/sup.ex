defmodule Hangman.Sup do
  @moduledoc false

  use Supervisor

  @me __MODULE__

  @spec start_link(term) :: Supervisor.on_start
  def start_link(:ok), do: Supervisor.start_link(@me, :ok, name: @me)

  ## Callbacks

  @spec init(term) :: {:ok, {:supervisor.sup_flags, [:supervisor.child_spec]}}
  def init(:ok) do
    [
      {Hangman.Server, :ok} # child spec relying on use GenServer...
    ]
    |> Supervisor.init(strategy: :simple_one_for_one)
  end
end
