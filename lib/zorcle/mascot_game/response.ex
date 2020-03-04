defmodule Zorcle.MascotGame.Response do
  defstruct ~w[guess game user_name correct]a

  alias Zorcle.MascotGame.Game

  def new(game, guess, user_name) do
    %__MODULE__{
      guess: guess,
      user_name: user_name,
      game: game,
      correct: correct?(game, guess)
    }
  end

  defp correct?(%Game{current_question: current_question} = game, guess) do
    current_question.mascot == guess
  end
end
