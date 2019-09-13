defmodule ZorcleWeb.MascotGameLive do
  use(Phoenix.LiveView)

  # called when the liveview is connected to
  def mount(_params, socket) do
    send(self(), :count)
    {:ok, assign(socket, :count, 0)}
  end

  # called whenever there is a state change and delivers new html down to the client to be diffed and "DOM updatedededed"
  def render(assigns) do
    ~L"""
    Welcome to the Mascot Game
    Count: <%= @count %>
    """
  end

  def handle_info(:count, socket) do
    Process.send_after(self(), :count, 1000)
    count = socket.assigns.count + 1
    {:noreply, assign(socket, :count, count)}
  end
end
