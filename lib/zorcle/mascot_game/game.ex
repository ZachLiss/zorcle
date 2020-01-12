defmodule Zorcle.MascotGame.Game do
  defstruct users: %{},
            name: "",
            game_status: :not_started,
            current_question: %{school: nil},
            winning_user: ""

  @winning_score 3

  alias __MODULE__
  alias Zorcle.MascotGame.Questions

  def new(name) do
    %Game{
      name: name
    }
  end

  def add_user(%Game{users: users} = game, user_name) do
    case Map.has_key?(users, user_name) do
      true ->
        {:ok, game}

      false ->
        updated_users = Map.put(users, user_name, 0)
        {:ok, %Game{game | users: updated_users}}
    end
  end

  # def get_user_score(%Game{users: users}, user_name) do
  #   case Map.fetch(users, user_name) do
  #     {:ok, score} -> score
  #     :error -> 0
  #   end
  # end

  def start_game(%Game{} = game) do
    game =
      game
      |> Map.put(:game_status, :started)
      |> Map.put(:current_question, get_random_question())

    {:ok, game}
  end

  def end_game(%Game{} = game) do
    game =
      game
      |> Map.put(:game_status, :ended)

    {:ok, game}
  end

  # answer question
  def answer_question(%Game{current_question: current_question} = game, guess, user_name) do
    case(current_question.mascot == guess) do
      true ->
        game =
          game
          |> increase_score_for_user(user_name)
          |> check_for_winning_user(user_name)
          |> Map.put(:current_question, get_random_question())

        {:ok, game}

      _ ->
        {:error, :incorrect}
    end
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
