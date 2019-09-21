defmodule ZorcleWeb.ConnectLive do
  use(Phoenix.LiveView)

  alias ZorcleWeb.MascotGameView

  def mount(_params, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    MascotGameView.render("connect.html")
  end
end
