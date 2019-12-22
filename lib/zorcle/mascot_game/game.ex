defmodule Zorcle.MascotGame.Game do
  defstruct users: %{},
            game_status: :not_started,
            current_question: %{school: nil},
            winning_user: ""

  @winning_score 3

  alias __MODULE__
  alias Zorcle.MascotGame.Questions

  def new() do
    %Game{}
  end

  def add_user(%Game{users: users} = game, user_name) do
    updated_users = Map.put(users, user_name, 0)
    %Game{game | users: updated_users}
  end

  def get_user_score(%Game{users: users}, user_name) do
    case Map.fetch(users, user_name) do
      :error -> 0
      {:ok, score} -> score
    end
  end

  # start game
  # end game
  # answer question
end
