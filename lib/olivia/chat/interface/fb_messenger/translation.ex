defmodule Olivia.Chat.Interface.FbMessenger.Translation do
  @moduledoc """
  Handles translating payloads received from FB
  """
  alias Olivia.Chat.Impression

  @doc """
  Translates standard text entry
  """
  def process_messages(%{
        "message" => %{
          "attachments" => [
            %{
              "payload" => %{
                "sticker_id" => _payload_sticker_id,
                "url" => url
              },
              "type" => "image"
            }
          ],
          "mid" => _fb_message_id,
          "sticker_id" => _message_sticker_id
        },
        "recipient" => %{"id" => recipient_id},
        "sender" => %{"id" => sender_id},
        "timestamp" => timestamp
      }) do
    %Impression{
      url: url,
      sender_id: sender_id,
      recipient_id: recipient_id,
      timestamp: timestamp,
      origin: :messenger,
      session_id: nil
    }
  end

  def process_messages(%{
    "message" => %{
      "mid" => _fb_mid,
      "text" => text
    },
    "recipient" => %{
      "id" => recipient_id
    },
    "sender" => %{
      "id" => sender_id
    },
    "timestamp" => timestamp
  }) do
    %Impression{
      message: text,
      sender_id: sender_id,
      recipient_id: recipient_id,
      timestamp: timestamp,
      origin: :messenger,
      session_id: nil
    }
  end
end
