defmodule ZorcleWeb.MascotGameLive do
  use(Phoenix.LiveView)

  # called when the liveview is connected to
  def mount(_params, socket) do
    {:ok, socket}
  end

  # called whenever there is a state change and delivers new html down to the client to be diffed and "DOM updatedededed"
  def render(assigns) do
    ~L"""
    Welcome to the Mascot Game
    """
  end
end
