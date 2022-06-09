defmodule IserverWeb.RoomChannel do
  use IserverWeb, :channel
  alias Iserver.{Room, RoomSupervisor, User, UserSupervisor}

  @impl true
  def join("room:" <> room_id, %{"id" => user_id, "name" => name}, socket) do
    socket =
      socket
      |> get_or_create_room(room_id)
      |> get_or_create_user(user_id, name, room_id)

    {:ok, %{me: socket.assigns.me, room: socket.assigns.room}, socket}
  end

  @impl true
  def handle_in("description", payload, socket) do
    broadcast! socket, "description", payload
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("ice", payload, socket) do
    broadcast! socket, "ice", payload
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("room", _, socket) do
    socket =
      socket
      |> update_room()
    {:reply, {:ok, socket.assigns.room}, socket}
  end

  @impl true
  def handle_in("close", _, socket = %{assigns: %{me: _me, room: _room}}) do
    {:reply, socket}
  end

  defp get_or_create_user(socket, user_id, name, room_id) do
    with user_pid when not is_nil(user_pid) <- UserSupervisor.get(user_id) do
      socket
      |> assign(:me, user_pid |> User.get())
    else
      _ ->
        with {:ok, user_pid} <- UserSupervisor.add(%{id: user_id, name: name, room_id: room_id}) do
          socket
          |> assign(:me, user_pid |> User.get())
        end
    end
  end

  defp get_or_create_room(socket, room_id) do
    with room_pid when not is_nil(room_pid) <- RoomSupervisor.get(room_id) do
      socket
      |> assign(:room, room_pid |> Room.get())
    else
      _ ->
        with {:ok, room_pid} <- RoomSupervisor.add(room_id) do
          socket
          |> assign(:room, room_pid |> Room.get())
        end
    end
  end

  defp update_room(socket = %{assigns: %{room: %{id: room_id}}}) do
    with room_pid when not is_nil(room_pid) <- RoomSupervisor.get(room_id) do
      socket
      |> assign(:room, room_pid |> Room.get())
    end
  end
end
