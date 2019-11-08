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

    # QUESTION: the template explodes whenever one of the assigns keys
    # that it is expecting is not present. I can fix this by adding some initial state
    # for those values. Is there a standard technique for setting up initial state
    # in a liveview?

    assigns = [
      user: user,
      # game_started: false,
      # current_question_school: nil,
      user_score: 0,
      mascot_guess: "",
      game_state: %{
        game_status: :not_started,
        current_question_school: "",
        users: [],
        winning_user: ""
      }
    ]

    {:ok, assign(socket, assigns)}
  end

  # called whenever there is a state change and delivers new html down to the client to be diffed and "DOM updatedededed"
  def render(assigns) do
    MascotGameView.render("game_board.html", assigns)
  end

  # Consume message from pubsub
  def handle_info({:update_game_state, game_state}, socket) do
    {:noreply, assign(socket, :game_state, game_state)}
  end

  def handle_event("toggle-game", _, socket) do
    # start with our state -> start the game -> grab a question -> return
    case(socket.assigns.game_state.game_status == :started) do
      false ->
        MascotGame.start_game()
        {:noreply, socket}

      _ ->
        MascotGame.end_game()
        {:noreply, socket}
    end
  end

  def handle_event("answer_question", %{"game_form" => %{"mascot" => guess}}, socket) do
    IO.puts("ANSWER QUESTION")

    case MascotGame.check_answer(guess, socket.assigns.user) do
      :ok ->
        # noop for now, we'll add correct/incorrect UI feedback later
        # also... what might be the best way to provide this feedback?
        # reset guess for correct answers
        {:noreply, assign(socket, :mascot_guess, "")}

      _ ->
        # TODO if incorrect pass back wrong answer to to provide feedback
        {:noreply, socket}
    end
  end

  def handle_event("update_mascot_guess", %{"game_form" => %{"mascot" => guess}}, socket) do
    {:noreply, assign(socket, :mascot_guess, guess)}
  end
end
