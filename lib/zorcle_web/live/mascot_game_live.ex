defmodule ZorcleWeb.MascotGameLive do
  use(Phoenix.LiveView)

  alias ZorcleWeb.MascotGameView
  alias Zorcle.MascotGame

  defp default_assigns do
  end

  # called when the liveview is connected to
  def mount(%{user: user}, socket) do
    assigns = [
      user: user,
      game_started: false,
      current_question_school: nil,
      user_score: 0,
      mascot_guess: ''
    ]

    {:ok, assign(socket, assigns)}
  end

  # called whenever there is a state change and delivers new html down to the client to be diffed and "DOM updatedededed"
  def render(assigns) do
    MascotGameView.render("game_board.html", assigns)
  end

  def handle_event("toggle-game", _, socket) do
    # start with our state -> start the game -> grab a question -> return
    case(socket.assigns.game_started) do
      false ->
        socket =
          socket
          |> update(:game_started, &(!&1))
          |> prepare_new_question

        {:noreply, socket}

      _ ->
        socket =
          socket
          |> assign(
            game_started: false,
            current_question_school: nil,
            user_score: 0,
            mascot_guess: ''
          )

        IO.inspect(socket)

        {:noreply, socket}
    end
  end

  def handle_event(
        "answer_question",
        %{"game_form" => %{"mascot" => guess}},
        %{assigns: %{current_question_school: correct_answer}} = socket
      ) do
    case MascotGame.check_answer(correct_answer, guess) do
      true ->
        new_socket =
          socket
          |> prepare_new_question
          |> update(:user_score, &(&1 + 1))

        {:noreply, new_socket}

      _ ->
        {:noreply, socket}
    end
  end

  defp prepare_new_question(socket) do
    # grab first question & broadcast it
    # do a socket assign?
    current_question = MascotGame.get_random_question()
    assign(socket, :current_question_school, current_question.school)
  end
end
