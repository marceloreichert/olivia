defmodule Olivia.Chat.Interface.WebApp.Entry do
  @moduledoc """
  Entry
  """

  alias Olivia.Chat.Conversation
  alias Olivia.Chat.Thinker
  alias Olivia.Chat.Interface.WebApp.Translation

  @bot_name Application.compile_env(:olivia, :bot_name)

  @doc """
  Entry point for messages
  """
  def entry_messages(payload) do
    payload
    |> Translation.translate_entry
    |> IO.inspect()
    |> Conversation.received_message
    |> IO.inspect()
    |> Thinker.run
    |> IO.inspect()
    |> @bot_name.Orchestra.run
    |> Conversation.sent_message
  end
end
