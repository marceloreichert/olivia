defmodule OliviaWeb.Chat.WebAppController do
  use OliviaWeb, :controller

  @bot_name Application.get_env(:olivia, :bot_name)

  def create(conn, params) do
    params
    |> Olivia.handle_messages
    |> @bot_name.Orchestra.run
    |> send_response(conn)
  end

  defp send_response(%{responses: responses} = impression, conn) do
    response = Poison.encode!(%{responses: responses})
    send_resp(conn, 200, response)
  end

end
