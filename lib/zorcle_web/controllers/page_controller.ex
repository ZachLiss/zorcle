defmodule ZorcleWeb.PageController do
  use ZorcleWeb, :controller

  def index(conn, _params) do
    case get_session(conn, :user) do
      nil ->
        # we dont have a user so lets render the select user route
        redirect(conn, to: Routes.session_path(conn, :new))

      user ->
        # we have a user so let's head to the join a game route
        redirect(conn, to: Routes.mascot_game_path(conn, :new))
    end
  end

  """
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
  """
end
