defmodule ZorcleWeb.MascotGameLive do
  use(Phoenix.LiveView)

  alias ZorcleWeb.MascotGameView
  alias Zorcle.MascotGame

  defp default_assigns do
  end

  # called when the liveview is connected to
  def mount(%{user: user}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Zorcle.InternalPubSub, "game")
      MascotGame.join_game(user.name)
    end

    assigns = [
      user: user,
      # game_started: false,
      # current_question_school: nil,
      user_score: 0,
      mascot_guess: "",
      game_state: %{
        game_status: :not_started,
        current_question_school: "",
        users: []
      }
    ]

    {:ok, assign(socket, assigns)}
  end

  # called whenever there is a state change and delivers new html down to the client to be diffed and "DOM updatedededed"
  def render(assigns) do
    IO.puts("==== rendering ====")
    IO.inspect(assigns)
    IO.puts("===================")
    MascotGameView.render("game_board.html", assigns)
  end

  # Consume message from pubsub
  def handle_info({:update_game_state, game_state}, socket) do
    {:noreply, assign(socket, :game_state, game_state)}
  end

  def handle_event("toggle-game", _, socket) do
    # start with our state -> start the game -> grab a question -> return
    case(socket.assigns.game_state.game_status == :game_started) do
      false ->
        MascotGame.start_game()
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
    # TODO make a call to answer_question on MascotGame
    # if correct update things and update game state
    # if incorrect pass back wrong answer to to provide feedback
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
