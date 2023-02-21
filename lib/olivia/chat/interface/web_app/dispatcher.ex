defmodule Olivia.Chat.Interface.WebApp.Dispatcher do
  @moduledoc """
  Dispatcher messages
  """

  alias Olivia.Chat.Conversation

  def send_response(%{responses: responses, sender_id: sender_id} = _message, _conn) do
    response = Jason.encode!(%{responses: responses})
    Conversation.sent_message(sender_id, response)
    response
  end
end
