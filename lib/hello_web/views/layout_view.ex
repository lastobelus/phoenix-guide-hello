defmodule HelloWeb.LayoutView do
  use HelloWeb, :view

  def logged_in?(conn) do
    not is_nil(Plug.Conn.get_session(conn, :user_id))
  end
end
