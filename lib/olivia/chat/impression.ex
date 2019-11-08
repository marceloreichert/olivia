defmodule Olivia.Chat.Impression do
  @moduledoc false
  defstruct message: nil, url: nil, sender_id: :init, recipient_id: :init, timestamp: :timestamp, origin: :atom, payload: nil, session_id: nil, intents: nil, entities: nil, context: nil, responses: nil
end
