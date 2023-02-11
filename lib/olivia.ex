defmodule Olivia do
  @moduledoc """
  Olivia keeps the contexts that define your domain and business logic.
  """

  def handle_messages(%{"object" => _object, "entry" => payload}) do
    payload
    |> Olivia.Chat.Interface.FbMessenger.Entry.entry_messages
  end

  def handle_messages(%{"input" => input} = _payload) do
    input
    |> Olivia.Chat.Interface.WebApp.Entry.entry_messages
  end
end
