defmodule Olivia.Chat.Interface.WebApp.Translation do
  @moduledoc """
  Handles translating payloads received from Web Applications
  """
  alias Olivia.Message

  @doc """
  Translates standard text entry
  """
  def translate_entry(payload) do
    uid = payload["user"]["uid"]
    text = payload["text"]

    struct(Message, %{
      text: text,
      sender_id: uid,
      recipient_id: uid,
      timestamp: nil,
      origin: :webapp,
      payload: payload
    })
  end
end
