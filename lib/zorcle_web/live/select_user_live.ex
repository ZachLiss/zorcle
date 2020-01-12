defmodule ZorcleWeb.SelectUserLive do
  use Phoenix.LiveView

  def mount(_session, socket) do
    assigns = [user_name: ""]
    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~L"""
    <form  phx-submit="submit_user_form">
    <div>
    <input type="text" name="user[username]" />
    </div>
    <button type="submit">Submit</button>
    </form>
    """
  end

  def handle_event("submit_user_form", %{"user" => %{"username" => username}}, socket) do
    IO.puts("user form submitted")
    IO.inspect(socket)

    {:noreply, socket}
  end
end
