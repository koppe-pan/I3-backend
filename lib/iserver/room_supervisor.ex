defmodule Iserver.RoomSupervisor do
  import DynamicSupervisor, only: [start_child: 2, which_children: 1, terminate_child: 2]
  alias Iserver.{Room}

  @server_mod Iserver.DynamicRoomSupervisor

  # Client

  def add(attrs) do
    start_child(@server_mod, {Room, attrs})
  end

  def delete(pid) do
    terminate_child(@server_mod, pid)
  end

  def get(room_id) do
    list_pid()
    |> Enum.find(fn
      pid ->
        Room.active(pid, room_id)
    end)
  end

  def list_pid() do
    which_children(@server_mod)
    |> Enum.map(fn({_, c, _, _}) -> c end)
  end
end
