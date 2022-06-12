defmodule Iserver.User do
  use GenServer

  @derive {Jason.Encoder, only: [:id, :name, :muted, :camera_on, :raising_hand, :volume]}
  defstruct id: "", name: "", muted: true, camera_on: false, raising_hand: false, volume: 100, room_id: "lobby"

  alias Iserver.ID

  # Client

  def start_link(attrs) do
    GenServer.start_link(__MODULE__, attrs)
  end

  def active(pid, id) do
    GenServer.call(pid, {:active, id})
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  # Server (callbacks)

  @impl true
  def init(%{name: name, room_id: room_id}) do
    id = inspect(System.system_time(:second))
         |> ID.sha256
    {:ok, %__MODULE__{id: id, name: name, room_id: room_id}}
  end

  @impl true
  def handle_call({:active, id}, _from, user = %__MODULE__{id: user_id}) do
    {:reply, id==user_id, user}
  end

  @impl true
  def handle_call(:get, _from, user) do
    {:reply, user, user}
  end
end
