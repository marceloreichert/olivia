defmodule Olivia.Message do
  @moduledoc """
  This struct holds all information about a message.
  """

  alias __MODULE__, as: Message

  defstruct text: nil,
            url: nil,
            sender_id: :init,
            recipient_id: :init,
            timestamp: :timestamp,
            origin: :atom,
            payload: nil,
            session_id: nil,
            intents: nil,
            entities: nil,
            context: nil,
            responses: nil,
            metadata: nil
end
