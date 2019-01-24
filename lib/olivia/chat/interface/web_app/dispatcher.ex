defmodule Olivia.Chat.Interface.WebApp.Dispatcher do
  @moduledoc """
  Dispatcher messages
  """

  alias Olivia.Chat.Conversation

  def send_response([]), do: []

  def send_response([h | t]) do
    [send_response(h) | send_response(t)]
  end

  def send_response(response) do
    Conversation.sent_message(response["recipient"]["id"], response)
    response
  end
end
