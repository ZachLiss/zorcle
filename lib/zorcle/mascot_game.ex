defmodule Zorcle.MascotGame do
  alias Zorcle.MascotGame.Questions

  def list_questions do
    Questions.get_questions()
  end

  def get_random_question do
    Questions.get_questions()
    |> Enum.random()
  end
end
