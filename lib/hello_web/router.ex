defmodule HelloWeb.Router do
  use HelloWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_current_user
    plug :put_user_token
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HelloWeb.Plugs.Locale, "en"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HelloWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/hello", HelloController, :index
    get "/hello/:messenger", HelloController, :show

    resources "/users", UserController

    resources "/sessions", SessionController,
      only: [:new, :create, :delete],
      singleton: true

    resources "/posts", PostController
  end

  scope "/cms", HelloWeb.CMS, as: :cms do
    pipe_through [:browser, :authenticate_user]

    resources "/pages", PageController
  end

  # Other scopes may use custom stacks.
  # scope "/api", HelloWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: HelloWeb.Telemetry, ecto_repos: [Hello.Repo]
    end
  end

  defp authenticate_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Login required")
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()

      _user_id ->
        conn
    end
  end

  defp put_current_user(conn, _) do
    IO.puts("put_current_user")

    case get_session(conn, :user_id) do
      nil ->
        IO.puts("...do nothing")
        conn

      user_id ->
        IO.puts("...lookup user #{user_id}")
        assign(conn, :current_user, Hello.Accounts.get_user!(user_id))
    end
  end

  defp put_user_token(conn, _) do
    IO.puts("put_current_user")

    if current_user = conn.assigns[:current_user] do
      IO.puts("...create token")
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      conn = assign(conn, :user_token, token)
      IO.puts("...#{conn.assigns[:user_token]}")
      conn
    else
      IO.puts("...do nothing")
      conn
    end
  end
end
