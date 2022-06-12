defmodule Iserver.UserSupervisor do
  import DynamicSupervisor, only: [start_child: 2, which_children: 1, terminate_child: 2]
  alias Iserver.{ID, User}

  @server_mod Iserver.DynamicUserSupervisor

  # Client

  def add(params = %{name: name, room_id: room_id}) do
    user_id = inspect(System.system_time(:nanosecond))
              |> ID.sha256
    if list() |> Enum.any?(fn %User{id: u_id} -> u_id == user_id end) do
      add(params)
    else
      start_child(@server_mod, {User, %{id: user_id, name: name, room_id: room_id}})
    end
  end

  def delete(pid) do
    terminate_child(@server_mod, pid)
  end

  def get(user_id) do
    list_pid()
    |> Enum.find(fn
      pid ->
        User.active(pid, user_id)
    end)
  end

  def list_pid() do
    which_children(@server_mod)
    |> Enum.map(fn({_, c, _, _}) -> c end)
  end

  def list() do
    list_pid()
    |> Enum.map(&User.get/1)
  end

  def list_by_room_id(room_id) do
    list()
    |> Enum.filter(fn %User{room_id: id} -> id==room_id end)
  end
end
