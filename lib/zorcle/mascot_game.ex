defmodule Zorcle.MascotGame do
  use GenServer

  alias Zorcle.MascotGame.Questions

  # TODO change into a genserver

  def start_link(_) do
    IO.puts("STARTING THE GAME GenServer")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    # initial state setup
    state = %{
      users: %{},
      game_status: :not_started,
      # we'll think about how to represent the used questions state
      used_questions: %{},
      current_question: %{school: nil}
    }

    {:ok, state}
  end

  def handle_call({:user_join, user_name}, {pid, _ref}, %{users: users} = state) do
    # use the pid to make a call to Phoenix.PubSub.subscribe/3

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

    # add this to pipeline?
    broadcast_updated_game_state(state)

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
          |> Map.put(:current_question, get_random_question())

        # add this to pipeline?
        broadcast_updated_game_state(state)

        {:reply, :ok, state}

      _ ->
        {:reply, :incorrect, state}
    end
  end

  defp increase_score_for_user(state, user_name) do
    # TODO can this be improved by refactoring?
    users =
      state.users
      |> Map.put(user_name, state.users[user_name] + 1)

    Map.put(state, :users, users)
  end

  defp broadcast_updated_game_state(state) do
    Phoenix.PubSub.broadcast(
      Zorcle.InternalPubSub,
      "game",
      {:update_game_state, state_for_lv(state)}
    )
  end

  defp state_for_lv(state) do
    # return some subset of the state from the GenServer
    %{
      current_question_school: state.current_question.school,
      users: state.users,
      game_status: state.game_status
    }
  end

  # client
  def join_game(name) do
    # name
    GenServer.call(__MODULE__, {:user_join, name})
  end

  def start_game() do
    GenServer.call(__MODULE__, {:start_game})
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
    is_correct = GenServer.call(__MODULE__, {:answer_question, guess, user.name})
  end
end
