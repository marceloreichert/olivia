defmodule Olivia.Chat.Interface.WebApp.Translation do
  @moduledoc """
  Handles translating payloads received from Web Applications
  """
  alias Olivia.Chat.Impression

  @doc """
  Translates standard text entry
  """
  def translate_entry(payload) do
    IO.inspect payload
    uid = payload["user"]["uid"]
    text = payload["text"]

    %Impression{
      message: text,
      sender_id: uid,
      recipient_id: uid,
      timestamp: nil,
      origin: :webapp,
      payload: payload
    }
  end
end
