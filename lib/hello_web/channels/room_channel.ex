defmodule HelloWeb.RoomChannel do
  use Phoenix.Channel
  alias HelloWeb.Presence

  @moduledoc false

  @impl true
  def join("room:lobby", _message, socket) do
    send(self(), :after_join)
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

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.current_user.username, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
