defmodule ZorcleWeb.MascotGameController do
  use ZorcleWeb, :controller
  plug(:require_user)

  def index(conn, _) do
    redirect(conn, to: Routes.mascot_game_path(conn, :new))
  end

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"mascot_game_name" => mascot_game_name}) do
    redirect(conn, to: Routes.mascot_game_path(conn, :show, mascot_game_name))
  end

  def show(conn, %{"id" => mascot_game_id}) do
    user = get_session(conn, :user)
    render(conn, "show.html", mascot_game_id: mascot_game_id, user: user)
  end

  defp require_user(conn, _) do
    case get_session(conn, :user) do
      nil ->
        conn
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()

      _ ->
        conn
    end
  end
end
