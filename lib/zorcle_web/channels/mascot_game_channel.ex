defmodule ZorcleWeb.MascotGameChannel do
  use ZorcleWeb, :channel

  alias Zorcle.MascotGame

  def join("mascot_game:" <> mascot_game_id, _params, socket) do
    # :timer.send_interval(5_000, :ping)
    {:ok, assign(socket, :mascot_game_id, String.to_integer(mascot_game_id))}
  end

  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push(socket, "ping", %{count: count})

    {:noreply, assign(socket, :count, count + 1)}
  end

  def handle_in("pong", _params, socket) do
    IO.puts("PONG: ")
    {:reply, :ok, socket}
  end

  def handle_in("start_game", _params, socket) do
    # do whatever stuff we need to do to start the game
    # broadcast start game
    broadcast!(socket, "start_game", %{})

    # grab first question & broadcast it
    # do a socket assign?
    current_question = MascotGame.get_random_question()
    socket = assign(socket, :current_question, current_question)

    broadcast!(socket, "new_question", %{
      school: current_question.school
    })

    {:reply, :ok, socket}
  end

  def handle_in("end_game", _params, socket) do
    # do whatever stuff we need to do to end the game
    # broadcast end game
    broadcast!(socket, "end_game", %{})
    {:reply, :ok, socket}
  end

  def handle_in("submit_answer", %{"mascot" => user_answer}, socket) do
    correct_answer = socket.assigns[:current_question].mascot

    case user_answer do
      ^correct_answer ->
        # broadcast next question
        {:reply, :ok, socket}

      _ ->
        {:reply, :incorrect, socket}
    end
  end

  def broadcast_new_question(socket) do
    # grab first question & broadcast it
    # do a socket assign?
    current_question = MascotGame.get_random_question()
    socket = assign(socket, :current_question, current_question)

    broadcast!(socket, "new_question", %{
      school: current_question.school
    })
  end
end
