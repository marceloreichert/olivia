defmodule Olivia.Application do
  @moduledoc false
  
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(OliviaWeb.Endpoint, []),
      supervisor(Registry, [:unique, Olivia.Chat.Conversation.Registry],
        id: Olivia.Chat.Conversation.Registry
      ),
      supervisor(Olivia.Chat.Conversation.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Olivia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    OliviaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
