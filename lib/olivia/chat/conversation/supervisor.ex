defmodule Olivia.Chat.Conversation.Supervisor do
  @moduledoc """
  Supervisor for conversation processes
  """
  use DynamicSupervisor

  alias Olivia.Chat.Conversation

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(child_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      %{id: Conversation, start: { Conversation, :start_link,  [child_name]}, restart: :transient})
  end
end
