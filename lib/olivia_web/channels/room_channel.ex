defmodule OliviaWeb.RoomChannel do
  use OliviaWeb, :channel

  @bot_name Application.get_env(:olivia, :bot_name)

  def join("olivia:" <> uid, payload, socket) do
    if authorized?(payload) do
      {:ok, %{channel: "olivia:#{uid}"}, assign(socket, :uid, uid)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("new_msg", payload, socket) do
    impression =
      payload
      |> Olivia.handle_messages
      |> @bot_name.Orchestra.run()

    # broadcast!(socket, "new_msg", %{message: impression.responses})
    broadcast!(socket, "new_msg", %{message: "TESTE"})

    {:reply, :ok, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
