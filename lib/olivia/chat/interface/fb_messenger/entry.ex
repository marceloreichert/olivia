defmodule Olivia.Chat.Interface.FbMessenger.Entry do
  @moduledoc """
  Translates fb message events into Olivia-friendly internal representations (Impressions)
  """

  alias Olivia.Chat.Interface.FbMessenger.Message
  alias Olivia.Chat.Interface.FbMessenger.Network

  @doc """
  Entry point for regular facebook messages
  """
  def process_messages([%{"messaging" => messaging} | _] = payload) do
    sender_id = hd(messaging)["sender"]["id"]
    token = Application.get_env(:olivia, :fb_page_access_token)

    start_typing_indicator(sender_id, token)

    payload
    |> Enum.each(&Message.process_messages/1)

    stop_typing_indicator(sender_id, token)
  end

  @doc """
  Sends a message to Facebook to signal typing.
  """
  def start_typing_indicator(sender_id, token) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{"id" => sender_id},
      "sender_action" => "typing_on"
    }
    |> Network.send_messenger_response(token)

    sender_id
  end

  @doc """
  Sends a message to Facebook to end typing signal.
  """
  def stop_typing_indicator(sender_id, token) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{"id" => sender_id},
      "sender_action" => "typing_off"
    }
    |> Network.send_messenger_response(token)
  end
end
