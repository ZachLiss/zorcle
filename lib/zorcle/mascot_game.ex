defmodule Zorcle.MascotGame do
  use GenServer, restart: :temporary

  alias Zorcle.MascotGame.{Game, Questions}

  @expiry_idle_timeout :timer.minutes(3)

  def start_link(mascot_game_name) do
    IO.puts("STARTING THE GAME GenServer #{mascot_game_name}")
    GenServer.start_link(__MODULE__, mascot_game_name, name: global_name(mascot_game_name))
  end

  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end

  @impl GenServer
  def init(mascot_game_name) do
    IO.puts("Starting mascot_game server for MascotGame: #{mascot_game_name}")
    {:ok, initial_state(mascot_game_name), @expiry_idle_timeout}
  end

  defp initial_state(name) do
    Game.new(name)
  end

  @impl GenServer
  def handle_call({:user_join, user_name}, {_pid, _ref}, %{users: users} = state) do
    IO.puts("#{user_name} is joining the game")

    case Game.add_user(state, user_name) do
      {:ok, game} ->
        broadcast_updated_game_state(game)
        {:reply, game, game, @expiry_idle_timeout}

      {:error, reason} ->
        # silently fail for now
        # user with this name already added to the game, so we just return the current game state
        {:reply, state, state, @expiry_idle_timeout}
    end
  end

  # how to handle "pushing" the updated state back to the LV? is that a thing we should do?

  @impl GenServer
  def handle_call({:start_game}, _pid, state) do
    IO.puts("Starting game")

    {:ok, game} = Game.start_game(state)
    broadcast_updated_game_state(game)
    {:reply, :ok, game, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:end_game}, _pid, state) do
    IO.puts("Ending game")

    {:ok, game} = Game.end_game(state)
    broadcast_updated_game_state(game)
    # {:reply, :ok, game}
    {:stop, :normal, game}
  end

  @impl GenServer
  def handle_info(:timeout, state) do
    IO.puts("Stopping mascot game server for #{state.name}")
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_call({:answer_question, guess, user_name}, _pid, state) do
    IO.puts("Correct Answer: #{state.current_question.mascot}")

    case(Game.answer_question(state, guess, user_name)) do
      {:ok, game} ->
        broadcast_updated_game_state(game)
        {:reply, :ok, game, @expiry_idle_timeout}

      _ ->
        {:reply, :incorrect, state, @expiry_idle_timeout}
    end
  end

  defp broadcast_updated_game_state(state) do
    Phoenix.PubSub.broadcast(
      Zorcle.InternalPubSub,
      mascot_game_topic(state.name),
      {:update_game_state, state}
    )

    state
  end

  # move this to the mascot game live module?
  # yup, this module should have no notion of a LiveView consuming anything that it does

  # client
  def join_game(mascot_game, name) do
    GenServer.call(mascot_game, {:user_join, name})
  end

  def start_game(mascot_game) do
    GenServer.call(mascot_game, {:start_game})
  end

  def end_game(mascot_game) do
    GenServer.call(mascot_game, {:end_game})
  end

  def check_answer(mascot_game, guess, user) do
    GenServer.call(mascot_game, {:answer_question, guess, user.name})
  end

  def mascot_game_topic(name) do
    "MascotGame:#{name}"
  end
end
