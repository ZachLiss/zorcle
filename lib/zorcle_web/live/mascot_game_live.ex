defmodule ZorcleWeb.MascotGameLive do
  use(Phoenix.LiveView)

  alias ZorcleWeb.MascotGameView
  alias Zorcle.{MascotGame, MascotGameManager}

  defp default_assigns do
  end

  # called when the liveview is connected to
  def mount(%{user: user, mascot_game_name: mascot_game_name}, socket) do
    mascot_game =
      if connected?(socket) do
        Phoenix.PubSub.subscribe(
          Zorcle.InternalPubSub,
          MascotGame.mascot_game_topic(mascot_game_name)
        )

        mascot_game_server = MascotGameManager.mascot_game(mascot_game_name)

        MascotGame.join_game(mascot_game_server, user.name)
      end

    # QUESTION: the template explodes whenever one of the assigns keys
    # that it is expecting is not present. I can fix this by adding some initial state
    # for those values. Is there a standard technique for setting up initial state
    # in a liveview?

    IO.inspect(mascot_game)

    assigns = [
      user: user,
      mascot_game_name: mascot_game_name,
      # game_started: false,
      # current_question_school: nil,
      user_score: 0,
      mascot_guess: "",
      game_state: state_for_lv(mascot_game)
    ]

    {:ok, assign(socket, assigns)}
  end

  # called whenever there is a state change and delivers new html down to the client to be diffed and "DOM updatedededed"
  def render(assigns) do
    MascotGameView.render("game_board.html", assigns)
  end

  # Consume message from pubsub
  def handle_info({:update_game_state, game_state}, socket) do
    {:noreply, assign(socket, :game_state, state_for_lv(game_state))}
  end

  defp state_for_lv(nil) do
    %{
      game_status: :not_started,
      current_question_school: "",
      users: [],
      winning_user: ""
    }
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

  def handle_event("join_game", _, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(
        Zorcle.InternalPubSub,
        MascotGame.mascot_game_topic(socket.assigns.mascot_game_name)
      )

      mascot_game = MascotGameManager.mascot_game(socket.assigns.mascot_game_name)

      MascotGame.join_game(mascot_game, socket.assigns.user.name)
    end
  end

  def handle_event("toggle-game", _, %{assigns: %{mascot_game_name: mascot_game_name}} = socket) do
    # start with our state -> start the game -> grab a question -> return
    case(socket.assigns.game_state.game_status == :started) do
      false ->
        MascotGame.start_game(MascotGameManager.mascot_game(mascot_game_name))
        {:noreply, socket}

      _ ->
        MascotGame.end_game(MascotGameManager.mascot_game(mascot_game_name))
        {:noreply, socket}
    end
  end

  def handle_event(
        "answer_question",
        %{"game_form" => %{"mascot" => guess}},
        %{assigns: %{mascot_game_name: mascot_game_name}} = socket
      ) do
    IO.puts("ANSWER QUESTION")

    case MascotGame.check_answer(
           MascotGameManager.mascot_game(mascot_game_name),
           guess,
           socket.assigns.user
         ) do
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
