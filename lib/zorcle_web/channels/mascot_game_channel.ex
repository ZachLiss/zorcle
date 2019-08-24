defmodule ZorcleWeb.MascotGameChannel do
  use ZorcleWeb, :channel

  def join("mascot_game:" <> mascot_game_id, _params, socket) do
    {:ok, assign(socket, :mascot_game_id, String.to_integer(mascot_game_id))}
  end
end
