defmodule ZorcleWeb.ConnectLive do
  use(Phoenix.LiveView)

  alias ZorcleWeb.MascotGameView

  def mount(_params, socket) do
    {:ok, socket}
  end

  def render(%{name: _name} = assigns) do
    ~L"""
    	<div>
    	  Welcome <%= @name %>
    	</div>
    """
  end

  def render(assigns) do
    MascotGameView.render("connect.html", assigns)
  end

  def handle_event("join", %{"user" => user}, socket) do
    name = user["name"]
    email = user["email"]

    {:noreply, assign(socket, name: name, email: email)}
  end
end
