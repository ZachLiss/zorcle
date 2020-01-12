defmodule ZorcleWeb.Router do
  use ZorcleWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(Phoenix.LiveView.Flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    # plug(ZorcleWeb.Auth)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ZorcleWeb do
    pipe_through(:browser)

    # live("/", ConnectLive)
    get("/", PageController, :index)
    # get("/session/:token", PageController, :add_session)

    resources("/mascot_games", MascotGameController, only: [:index, :new, :show, :create])

    get("/login", SessionController, :new)
    post("/login", SessionController, :create)
    get("/logout", SessionController, :delete)

    # get("/logout", PageController, :drop_session)
    # resources("/users", UserController, only: [:index, :show, :new, :create])
  end

  # Other scopes may use custom stacks.
  # scope "/api", ZorcleWeb do
  #   pipe_through :api
  # end
end
