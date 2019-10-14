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
      current_question: %{}
    }

    {:ok, state}
  end

  def handle_call({:user_join, user_name}, _pid, %{users: users} = state) do
    IO.puts("#{user_name} is joining the game")
    users = Map.put(users, user_name, 0)
    state = Map.put(state, :users, users)

    # we may want to return a value, handle situations where users cannot join
    {:reply, :ok, state}
  end

  # how to handle "pushing" the updated state back to the LV? is that a thing we should do?

  def handle_call({:start_game}, _pid, %{game_status: game_status} = state) do
    state = Map.put(state, :game_status, :started)
    IO.puts("Starting game")
    {:reply, :ok, state}
  end

  def handle_call({:get_game_state}, _pid, state) do
    {:reply, state, state}
  end

  # client
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

  def check_answer(school, mascot) do
    # what is better to return here?
    [question_for_school] = Questions.get_question_by_school(school)
    question_for_school.mascot == mascot
  end
end
