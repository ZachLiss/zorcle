defmodule ZorcleWeb.MascotGameLive do
  use(Phoenix.LiveView)

  # called when the liveview is connected to
  def mount(%{user: user}, socket) do
    assigns = [
      user: user
    ]

    {:ok, assign(socket, assigns)}
  end

  # called whenever there is a state change and delivers new html down to the client to be diffed and "DOM updatedededed"
  def render(assigns) do
    ~L"""
    <h1>Welcome, <%= @user.name %>, to the Mascot Game</h1>
    """
  end
end
