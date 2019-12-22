defmodule Zorcle.MascotGame do
  use GenServer

  alias Zorcle.MascotGame.{Game, Questions}

  def start_link(_) do
    IO.puts("STARTING THE GAME GenServer")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    {:ok, initial_state()}
  end

  defp initial_state do
    Game.new()
  end

  def handle_call({:user_join, user_name}, {_pid, _ref}, %{users: users} = state) do
    IO.puts("#{user_name} is joining the game")

    case Game.add_user(state, user_name) do
      {:ok, game} ->
        broadcast_updated_game_state(game)
        {:reply, :ok, game}

      {:error, _} ->
        # silently fail for now
        {:reply, :ok, state}
    end
  end

  # how to handle "pushing" the updated state back to the LV? is that a thing we should do?

  def handle_call({:start_game}, _pid, state) do
    IO.puts("Starting game")

    {:ok, game} = Game.start_game(state)
    broadcast_updated_game_state(game)
    {:reply, :ok, game}
  end

  def handle_call({:end_game}, _pid, state) do
    IO.puts("Ending game")

    {:ok, game} = Game.end_game(state)
    broadcast_updated_game_state(game)
    {:reply, :ok, game}
  end

  def handle_call({:answer_question, guess, user_name}, _pid, state) do
    IO.puts("Correct Answer: #{state.current_question.mascot}")

    case(Game.answer_question(state, guess, user_name)) do
      {:ok, game} ->
        broadcast_updated_game_state(game)
        {:reply, :ok, game}

      _ ->
        {:reply, :incorrect, state}
    end
  end

  defp broadcast_updated_game_state(state) do
    Phoenix.PubSub.broadcast(
      Zorcle.InternalPubSub,
      "game",
      {:update_game_state, state_for_lv(state)}
    )

    state
  end

  # move this to the mascot game live module?
  defp state_for_lv(state) do
    # return some subset of the state from the GenServer to be consumed by mascot_game_live
    %{
      current_question_school: state.current_question.school,
      users: state.users,
      game_status: state.game_status,
      winning_user: state.winning_user
    }
  end

  # client
  def join_game(name) do
    GenServer.call(__MODULE__, {:user_join, name})
  end

  def start_game() do
    GenServer.call(__MODULE__, {:start_game})
  end

  def end_game() do
    GenServer.call(__MODULE__, {:end_game})
  end
end
