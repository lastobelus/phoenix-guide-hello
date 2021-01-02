defmodule HelloWeb.RoomChannelTest do
  use HelloWeb.ChannelCase

  alias Hello.Accounts

  def fixture(:user) do
    {:ok, user} =
      Accounts.create_user(%{
        name: "channel test",
        username: "channel_test",
        credential: %{email: "channel_test@example.com"}
      })

    user
  end

  setup do
    user = fixture(:user)
    # token = Phoenix.Token.sign(@endpoint, "user socket", user.id)

    {:ok, _, socket} =
      HelloWeb.UserSocket
      |> socket("user_id", %{current_user: user})
      |> subscribe_and_join(HelloWeb.RoomChannel, "room:lobby")

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to room:lobby", %{socket: socket} do
    push(socket, "shout", %{"hello" => "all"})
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
