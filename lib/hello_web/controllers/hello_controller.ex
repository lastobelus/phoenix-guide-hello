defmodule HelloWeb.HelloController do
  use HelloWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"messenger" => messenger} = params) do
    # to illustrate how to destructure in signature and still have access to whole params
    IO.puts("params2: #{inspect(params)}")
    render(conn, "show.html", messenger: messenger)
  end
end
