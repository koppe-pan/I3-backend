defmodule Iserver.UserSupervisor do
  import DynamicSupervisor, only: [start_child: 2, which_children: 1, terminate_child: 2]
  alias Iserver.{User}

  @server_mod Iserver.DynamicUserSupervisor

  # Client

  def add(attrs) do
    start_child(@server_mod, {User, attrs})
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
