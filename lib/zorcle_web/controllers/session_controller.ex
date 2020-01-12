defmodule ZorcleWeb.SessionController do
  use ZorcleWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"name" => name}}) do
    conn
    |> put_session(:user, %{name: name})
    |> put_flash(:info, "Welcome, #{name}")
    |> render("new.html")
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
