defmodule ZorcleWeb.MascotGameChannel do
  use ZorcleWeb, :channel

  def join("mascot_game:" <> mascot_game_id, _params, socket) do
    # :timer.send_interval(5_000, :ping)
    {:ok, assign(socket, :mascot_game_id, String.to_integer(mascot_game_id))}
  end

  def handle_info(:ping, socket) do
    count = socket.assigns[:count] || 1
    push(socket, "ping", %{count: count})

    {:noreply, assign(socket, :count, count + 1)}
  end

  def handle_in("pong", _params, socket) do
    IO.puts("PONG: ")
    {:reply, :ok, socket}
  end
end
