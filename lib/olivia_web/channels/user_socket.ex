defmodule OliviaWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "olivia:*", OliviaWeb.RoomChannel

  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
