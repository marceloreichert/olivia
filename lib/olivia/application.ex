defmodule Olivia.Application do
  @moduledoc false

  use Application

  @registry :conversations_registry

  def start(_type, _args) do
    children = [
      OliviaWeb.Endpoint,
      {Registry, [keys: :unique, name: @registry]},
      {Olivia.Chat.Conversation.Supervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Olivia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Olivia.Endpoint.config_change(changed, removed)
    :ok
  end
end
