defmodule Olivia.Chat.Interface.WebApp.Dispatcher do
  @moduledoc """
  Dispatcher messages
  """

  alias Olivia.Chat.Conversation

  def send_messenger_response([]), do: []

  def send_messenger_response([h | t]) do
    [send_messenger_response(h) | send_messenger_response(t)]
  end

  def send_messenger_response(response) do
    Conversation.sent_message(response["recipient"]["id"], response)
    response
  end
end
