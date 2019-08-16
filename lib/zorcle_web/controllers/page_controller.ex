defmodule ZorcleWeb.PageController do
  use ZorcleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
