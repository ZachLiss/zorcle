defmodule ZorcleWeb.PageController do
  use ZorcleWeb, :controller

  def index(conn, _params) do
    case get_session(conn, :user) do
      nil ->
        # session data should be minimal
        live_render(conn, ZorcleWeb.ConnectLive, session: %{})

      user ->
        live_render(conn, ZorcleWeb.MascotGameLive, session: %{user: user})
    end
  end

  def add_session(conn, %{"token" => token}) do
    case Zorcle.MagicLinks.verify_token(token) do
      {:ok, user} ->
        put_session(conn, :user, user)

      {:error, _} ->
        conn
    end
    |> redirect(to: "/")
  end

  def drop_session(conn, _) do
    conn
    |> delete_session(:user)
    |> redirect(to: "/")
  end
end
