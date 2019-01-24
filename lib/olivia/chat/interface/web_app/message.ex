defmodule Olivia.Chat.Interface.WebApp.Message do
  @moduledoc """
  Handles message events from Web Applications
  """

  alias Olivia.Chat.Conversation
  alias Olivia.Chat.Thinker
  alias Olivia.Chat.Interface.WebApp.Translation

  def process_messages(payload) do
    payload
    |> Translation.translate_entry
    |> Conversation.received_message
    |> Thinker.run
  end
end
