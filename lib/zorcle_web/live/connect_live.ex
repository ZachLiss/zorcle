defmodule ZorcleWeb.ConnectLive do
  use(Phoenix.LiveView)
  import Ecto.Changeset

  alias Zorcle.MagicLinks
  alias ZorcleWeb.MascotGameView

  def mount(_params, socket) do
    assigns = [
      changeset: join_changeset()
    ]

    {:ok, assign(socket, assigns)}
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
    user
    |> join_changeset()
    |> Map.put(:action, :errors)
    |> case do
      %{valid?: true, changes: %{name: name, email: email} = user} ->
        token = MagicLinks.create_token(user)
        {:noreply, redirect(socket, to: "/session/#{token}")}

      %{valid?: false} = changeset ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @types %{
    name: :string,
    email: :string
  }

  def join_changeset(attrs \\ %{}) do
    cast(
      {%{}, @types},
      attrs,
      [:name, :email]
    )
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/.+@.+/)
  end
end
