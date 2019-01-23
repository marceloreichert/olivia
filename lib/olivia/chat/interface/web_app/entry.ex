defmodule Olivia.Chat.Interface.WebApp.Entry do
  @moduledoc """
  Translates WebApp post message events into Olivia-friendly internal representations (Impressions)
  """

  alias Olivia.Chat.Interface.WebApp.Message

  @doc """
  Entry point for regular messages (free text)
  """
  def process_messages(payload) do
    payload
    |> Message.received_message
  end
end
