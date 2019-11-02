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
        # TODO reset the game... probably a MascotGame.end_game() type of thing
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

  def handle_event("answer_question", %{"game_form" => %{"mascot" => guess}}, socket) do
    # TODO make a call to answer_question on MascotGame
    # if correct update things and update game state
    # if incorrect pass back wrong answer to to provide feedback
    case MascotGame.check_answer(guess, socket.assigns.user) do
      true ->
        # noop for now, we'll add correct/incorrect UI feedback later
        # also... what might be the best way to provide this feedback?
        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end
end
