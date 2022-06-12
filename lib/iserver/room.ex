defmodule Iserver.Room do
  use GenServer
  alias Iserver.{Comment, UserSupervisor}

  defstruct id: nil, comments: []

  # Client

  def start_link(attrs) do
    GenServer.start_link(__MODULE__, attrs)
  end

  def comment(pid, c = %Comment{}) do
    GenServer.call(pid, {:comment, c})
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
  def handle_call({:comment, c = %Comment{}}, _from, room = %__MODULE__{comments: comments}) do
    updated_comments = [c | comments]
    {:reply, updated_comments, %__MODULE__{room | comments: updated_comments}}
  end

  @impl true
  def handle_call(:get, _from, room = %__MODULE__{id: room_id, comments: comments}) do
    {:reply, %{id: room_id, comments: comments, users: UserSupervisor.list_by_room_id(room_id)}, room}
  end
end
