defmodule Iserver.Room do
  use GenServer
  alias Iserver.{User, UserSupervisor}

  @derive {Jason.Encoder, only: [:id]}
  defstruct id: nil

  # Client

  def start_link(attrs) do
    GenServer.start_link(__MODULE__, attrs)
  end

  def add(pid, user) do
    GenServer.call(pid, {:add, user})
  end

  def delete(pid, user) do
    GenServer.call(pid, {:delete, user})
  end

  def active(pid, id) do
    GenServer.call(pid, {:active, id})
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  # Server (callbacks)

  @impl true
  def init(id) do
    {:ok, %__MODULE__{id: id}}
  end

  @impl true
  def handle_call({:active, id}, _from, room = %__MODULE__{id: room_id}) do
    {:reply, id==room_id, room}
  end

  @impl true
  def handle_call(:get, _from, room = %__MODULE__{id: room_id}) do
    {:reply, %{id: room_id, users: UserSupervisor.list_by_room_id(room_id)}, room}
  end
end
