defmodule Olivia.Chat.Interface.FbMessenger.Message do
  @moduledoc """
  Handles message events from Facebook Messenger
  """

  alias Olivia.Chat.Conversation
  alias Olivia.Chat.Thinker
  alias Olivia.Chat.Interface.FbMessenger.Translation
  alias Olivia.Chat.Interface.FbMessenger.Network

  def process_messages(%{"messaging" => [payload | _]}) do
    sender_id = payload["sender"]["id"]
    recipient_id = payload["recipient"]["id"]
    token = Application.get_env(:olivia, :fb_page_access_token)

    payload
    |> Translation.process_messages
    |> Conversation.received_message
    |> Thinker.run
    |> build_response(sender_id, token)
  end

  def build([], sender_id, token) do
     build_response("", sender_id, token)
   end
  def build([h | t], sender_id, token) do
    [build_response(h[:text], sender_id, token) | build(t, sender_id, token)]
  end

  def build_response(%{responses: responses} = impression, sender_id, token) do
    responses
    |> build(sender_id, token)
  end
  def build_response(text, sender_id, token) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{"id" => sender_id},
      "message" => %{
        "text" => text
      }
    }
    |> Network.send_messenger_response(token)
  end
end
