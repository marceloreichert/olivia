defmodule Olivia.Chat.Impression do
  @moduledoc false
  @behaviour Access

  defstruct message: nil,
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
            last_state: nil
  use Accessible

end
