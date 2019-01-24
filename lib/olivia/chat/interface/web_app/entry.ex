defmodule Olivia.Chat.Interface.WebApp.Entry do
  @moduledoc """
  Entry
  """

  alias Olivia.Chat.Interface.WebApp.Message

  @doc """
  Entry point for messages
  """
  def process_messages(payload) do
    payload
    |> Enum.each(&Message.process_messages/1)
  end
end
