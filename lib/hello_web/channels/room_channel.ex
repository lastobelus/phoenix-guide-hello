defmodule HelloWeb.RoomChannel do
  use Phoenix.Channel
  @moduledoc false

  @impl true
  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  @impl true
  def join("room:" <> _private_room_id, _params, _socket) do
    # here is where we would perform authorization, for example looking up a room in the database.
    {:error, %{reason: "unauthorized"}}
  end

  @impl true
  def join(_room, _message, _socket) do
    {:error, %{reason: "unknown topic"}}
  end

  @impl true
  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end
