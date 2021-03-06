defmodule Iserver.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      IserverWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Iserver.PubSub},
      # Start the Endpoint (http/https)
      IserverWeb.Endpoint,
      # Start a worker by calling: Iserver.Worker.start_link(arg)
      # {Iserver.Worker, arg}
      #{Iserver.Room, "lobby"},
      {DynamicSupervisor,
       strategy: :one_for_one, restart: :temporary, name: Iserver.DynamicRoomSupervisor},
      {DynamicSupervisor,
       strategy: :one_for_one, restart: :temporary, name: Iserver.DynamicUserSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Iserver.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IserverWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
