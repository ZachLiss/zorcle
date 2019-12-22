defmodule MascotGame.GameTest do
  use ExUnit.Case

  alias Zorcle.MascotGame.Game

  test "can add a user to a game and get their score" do
    game =
      Game.new()
      |> Game.add_user("zach")

    assert Game.get_user_score(game, "zach") == 0
    assert Game.get_user_score(game, "not zach") == 0
  end
end
