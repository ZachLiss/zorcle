defmodule Zorcle.MascotGame.Game do
  defstruct users: %{},
            name: "",
            game_status: :not_started,
            current_question: %{school: nil},
            last_response: nil,
            winning_user: ""

  @winning_score 3

  alias __MODULE__
  alias Zorcle.MascotGame.{Response, Questions}

  def new(name) do
    %Game{
      name: name
    }
  end

  def add_user(%Game{users: users} = game, user_name) do
    updated_users = Map.update(users, user_name, 0, & &1)
    %Game{game | users: updated_users}
  end

  # def get_user_score(%Game{users: users}, user_name) do
  #   case Map.fetch(users, user_name) do
  #     {:ok, score} -> score
  #     :error -> 0
  #   end
  # end

  def start_game(%Game{} = game) do
    game
    |> update_game_status(:started)
    |> select_question()
  end

  defp update_game_status(game, status) do
    Map.put(game, :game_status, status)
  end

  defp select_question(game) do
    Map.put(game, :current_question, get_random_question())
  end

  def end_game(%Game{} = game) do
    game
    |> update_game_status(:ended)
  end

  # answer question
  def answer_question(%Game{current_question: current_question} = game, guess, user_name)
      when is_binary(guess) do
    response = Response.new(game, guess, user_name)

    game
    |> add_response_to_game(response)
    |> answer_question(response, user_name)
  end

  def answer_question(game, %Response{correct: true} = response, user_name) do
    game =
      game
      |> increase_score_for_user(user_name)
      |> check_for_winning_user(user_name)
      |> select_question()

    game
  end

  def answer_question(game, %Response{correct: false} = response, _user_name) do
    game
  end

  defp add_response_to_game(game, response) do
    Map.put(game, :last_response, response)
  end

  defp increase_score_for_user(%Game{} = game, user_name) do
    users =
      game.users
      |> Map.put(user_name, game.users[user_name] + 1)

    Map.put(game, :users, users)
  end

  defp check_for_winning_user(%Game{users: users} = game, user_name) do
    if Map.get(users, user_name) >= @winning_score do
      Map.put(game, :winning_user, user_name)
    else
      game
    end
  end

  ### pulled from Zorcle.MascotGame
  def list_questions do
    Questions.get_questions()
  end

  def get_random_question do
    Questions.get_questions()
    |> Enum.random()
  end
end
