defmodule OliviaWeb.Chat.WebAppController do
  use OliviaWeb, :controller

  @bot_name Application.get_env(:olivia, :bot_name)

  def create(conn, params) do
    params
    |> Olivia.handle_messages
    |> send_response(conn)
  end

  defp send_response(%{responses: responses, sender_id: sender_id} = impression, conn) do
    send_resp(conn, 200, responses |> response_encode)
  end

  defp response_encode(responses) do
    response = Jason.encode!(%{responses: responses})
  end
end
