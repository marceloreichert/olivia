defmodule Olivia.Chat.Interface.FbMessenger.Entry do
  @moduledoc """
  Translates fb message events into Olivia-friendly internal representations (Impressions)
  """

  alias Olivia.Chat.Conversation
  alias Olivia.Chat.Thinker
  alias Olivia.Chat.Interface.FbMessenger.Translation
  alias Olivia.Chat.Interface.FbMessenger.Dispatcher

  @bot_name Application.compile_env(:olivia, :bot_name)

  @doc """
  Entry messages
  """
  def entry_messages([%{"messaging" => messaging}] = _payload) do
    messaging
    |> Enum.map(&filter_message/1)
  end

  defp filter_message(%{"message" => _} = message), do: process_message(message)

  defp filter_message(%{"postback" => _} = message), do: process_message(message)

  defp filter_message(_), do: nil

  def process_message(message) do
    message
    |> start_typing_indicator()
    |> Translation.process_messages()
    |> Conversation.received_message()
    |> Thinker.call()
    |> @bot_name.Orchestra.call()
    |> IO.inspect(label: "Return Message --> ")
    |> Dispatcher.build_response()
    |> stop_typing_indicator()
  end

  defp start_typing_indicator(%{"sender" => %{"id" => sender_id}} = message) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{"id" => sender_id},
      "sender_action" => "typing_on"
    }
    |> Dispatcher.send_response()

    message
  end

  defp stop_typing_indicator(%{sender_id: sender_id} = _message) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{"id" => sender_id},
      "sender_action" => "typing_off"
    }
    |> Dispatcher.send_response()
  end
end
