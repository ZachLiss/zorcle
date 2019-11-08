defmodule Zorcle.MascotGame do
  use GenServer

  alias Zorcle.MascotGame.Questions

  def start_link(_) do
    IO.puts("STARTING THE GAME GenServer")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    {:ok, initial_state()}
  end

  defp initial_state do
    %{
      users: %{},
      game_status: :not_started,
      # we'll think about how to represent the used questions state
      used_questions: %{},
      current_question: %{school: nil},
      winning_user: ""
    }
  end

  def handle_call({:user_join, user_name}, {_pid, _ref}, %{users: users} = state) do
    IO.puts("#{user_name} is joining the game")
    # calling Phoennix.PubSub.subscribe/3 with a pid is deprecated now
    # Phoenix.PubSub.subscribe(Zorcle.InternalPubSub, pid, "game")
    users = Map.put(users, user_name, 0)
    state = Map.put(state, :users, users)

    game_state = %{
      # how to handle cases when properties may not exist?
      # before the game is started the current_question wont have a school
      current_question_school: state.current_question.school,
      users: state.users,
      game_status: state.game_status
    }

    broadcast_updated_game_state(state)

    # we may want to return a value, handle situations where users cannot join
    {:reply, game_state, state}
  end

  # how to handle "pushing" the updated state back to the LV? is that a thing we should do?

  def handle_call({:start_game}, _pid, state) do
    IO.puts("Starting game")

    state =
      state
      |> Map.put(:game_status, :started)
      |> Map.put(:current_question, get_random_question())
      |> broadcast_updated_game_state

    {:reply, :ok, state}
  end

  def handle_call({:end_game}, _pid, state) do
    users_with_no_score = Map.new(state.users, fn {k, _v} -> {k, 0} end)

    state =
      initial_state
      |> Map.put(:users, users_with_no_score)
      |> broadcast_updated_game_state

    {:reply, :ok, state}
  end

  def handle_call({:get_game_state}, _pid, state) do
    game_state = %{
      current_question_school: state.current_question.school,
      users: state.users,
      game_status: state.game_status
    }

    {:reply, game_state, state}
  end

  def handle_call({:answer_question, guess, user_name}, _pid, state) do
    IO.puts("Correct Answer: #{state.current_question.mascot}")

    case(state.current_question.mascot == guess) do
      true ->
        state =
          state
          |> increase_score_for_user(user_name)
          |> check_for_winning_user(user_name)
          |> Map.put(:current_question, get_random_question())
          |> broadcast_updated_game_state

        {:reply, :ok, state}

      _ ->
        {:reply, :incorrect, state}
    end
  end

  defp increase_score_for_user(state, user_name) do
    users =
      state.users
      |> Map.put(user_name, state.users[user_name] + 1)

    Map.put(state, :users, users)
  end

  defp check_for_winning_user(%{users: users} = state, user_name) do
    if Map.get(users, user_name) >= 3 do
      Map.put(state, :winning_user, user_name)
    else
      state
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
    IO.puts("ending game")
    GenServer.call(__MODULE__, {:end_game})
  end

  # might not need this anymore since we can push state with our PubSub.broadcast
  def get_game_state do
    GenServer.call(__MODULE__, {:get_game_state})
  end

  def list_questions do
    Questions.get_questions()
  end

  def get_random_question do
    Questions.get_questions()
    |> Enum.random()
  end

  def check_answer(guess, user) do
    IO.puts("User: #{user.name}")
    GenServer.call(__MODULE__, {:answer_question, guess, user.name})
  end
end
