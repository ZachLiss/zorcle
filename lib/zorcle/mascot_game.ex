defmodule Zorcle.MascotGame do
  alias Zorcle.MascotGame.Questions

  def list_questions do
    Questions.get_questions()
  end

  def get_random_question do
    Questions.get_questions()
    |> Enum.random()
  end

  def check_answer(school, mascot) do
    # what is better to return here?
    [question_for_school] = Questions.get_question_by_school(school)
    question_for_school.mascot == mascot
  end
end
