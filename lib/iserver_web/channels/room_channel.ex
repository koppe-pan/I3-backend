defmodule IserverWeb.RoomChannel do
  use IserverWeb, :channel
  alias Iserver.{Room, RoomSupervisor, User, UserSupervisor}

  @impl true
  def join("room:" <> room_id, %{"id" => user_id, "name" => name}, socket) do
    socket =
      socket
      |> get_or_create_room(room_id)
      |> get_or_create_user(user_id, name, room_id)
      |> update_room()

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
  def handle_in("comment", content, socket = %{assigns: %{me: %User{id: user_id, room_id: room_id}}}) do
    with room_pid when not is_nil(room_pid) <- RoomSupervisor.get(room_id) do
      comment = Comment.create(%{user_id: user_id, content: content})
      with {:ok, _} <- room_pid
                       |> Room.comment(comment) do
        broadcast! socket, "comment", comment

        {:reply, {:ok, content}, socket
                                 |> update_room()}
      end
    end
  end

  @impl true
  def handle_in("close", _, socket = %{assigns: %{me: %User{id: user_id}}}) do
    UserSupervisor.delete(user_id)
    {:noreply,
      socket
      |> assign(me: nil)
      |> assign(room: nil)}
  end

  intercept ["description", "ice"]

  @impl true
  def handle_out("description", payload = %{"destinationId" => destination_id}, socket = %{assigns: %{me: %User{id: user_id}}}) do
    if destination_id == user_id, do: push(socket, "description", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_out("ice", payload = %{"destinationId" => destination_id}, socket = %{assigns: %{me: %User{id: user_id}}}) do
    if destination_id == user_id, do: push(socket, "ice", payload)
    {:noreply, socket}
  end

  defp get_or_create_user(socket, user_id, name, room_id) do
    with user_pid when not is_nil(user_pid) <- UserSupervisor.get(user_id) do
      socket
      |> assign(:me, user_pid |> User.get())
    else
      _ ->
        with {:ok, user_pid} <- UserSupervisor.add(%{name: name, room_id: room_id}) do
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
