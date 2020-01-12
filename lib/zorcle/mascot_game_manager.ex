defmodule Zorcle.MascotGameManager do
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def start_link() do
    IO.puts("Starting mascot_game_manager.")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def mascot_game(mascot_game_name) do
    existing_process(mascot_game_name) || new_process(mascot_game_name)
  end

  def existing_process(mascot_game_name) do
    Zorcle.MascotGame.whereis(mascot_game_name)
  end

  def new_process(mascot_game_name) do
    case start_child(mascot_game_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(mascot_game_name) do
    DynamicSupervisor.start_child(__MODULE__, {Zorcle.MascotGame, mascot_game_name})
  end
end
