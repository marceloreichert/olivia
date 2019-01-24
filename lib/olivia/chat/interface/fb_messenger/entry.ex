defmodule Olivia.Chat.Interface.FbMessenger.Entry do
  @moduledoc """
  Translates fb message events into Olivia-friendly internal representations (Impressions)
  """

  alias Olivia.Chat.Conversation
  alias Olivia.Chat.Thinker
  alias Olivia.Chat.Interface.FbMessenger.Translation
  alias Olivia.Chat.Interface.FbMessenger.Dispatcher

  @doc """
  Entry messages
  """
  def entry_messages([%{"messaging" => messaging} | _] = payload) do
    sender_id = hd(messaging)["sender"]["id"]
    token = Application.get_env(:olivia, :fb_page_access_token)

    start_typing_indicator(sender_id, token)

    payload
    |> Enum.each(&process_messages/1)

    stop_typing_indicator(sender_id, token)
  end

  def process_messages(%{"messaging" => [payload | _]}) do
    sender_id = payload["sender"]["id"]
    recipient_id = payload["recipient"]["id"]
    token = Application.get_env(:olivia, :fb_page_access_token)

    payload
    |> Translation.process_messages
    |> Conversation.received_message
    |> Thinker.run
    |> Dispatcher.build_response(sender_id, token)
  end

  @doc """
  Sends a message to Facebook to signal typing.
  """
  defp start_typing_indicator(sender_id, token) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{"id" => sender_id},
      "sender_action" => "typing_on"
    }
    |> Dispatcher.send_response(token)

    sender_id
  end

  @doc """
  Sends a message to Facebook to end typing signal.
  """
  defp stop_typing_indicator(sender_id, token) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{"id" => sender_id},
      "sender_action" => "typing_off"
    }
    |> Dispatcher.send_response(token)
  end
end
