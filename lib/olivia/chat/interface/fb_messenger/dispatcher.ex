defmodule Olivia.Chat.Interface.FbMessenger.Dispatcher do
  @moduledoc """
  Dispatcher messages
  """

  alias Olivia.Chat.Conversation

  @page_access_token Application.get_env(:olivia, :fb_page_access_token)
  @headers [{"Content-Type", "application/json"}]

  def send_response([]), do: []

  def send_response([h | t]) do
    [send_response(h) | send_response(t)]
  end

  def send_response(response) do
    url = "https://graph.facebook.com/v2.11/me/messages?access_token=#{@page_access_token}"

    case HTTPoison.post(url, Jason.encode!(response), @headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Conversation.sent_message(response["recipient"]["id"], response)
        :ok

      error ->
        error
    end
  end

  def send_response(response, token) do
    url = "https://graph.facebook.com/v2.6/me/messages?access_token=#{token}"

    case HTTPoison.post(url, Jason.encode!(response), @headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Conversation.sent_message(response["recipient"]["id"], response)
        :ok

      error ->
        error
    end
  end

  def build_response(%{responses: responses} = impression, sender_id, token) do
    responses
    |> build(sender_id, token)
  end
  def build_response(text, sender_id, token) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{"id" => sender_id},
      "message" => %{
        "text" => text
      }
    }
    |> send_response(token)
  end

  def build([], sender_id, token) do
     build_response("", sender_id, token)
   end
  def build([h | t], sender_id, token) do
    [build_response(h[:text], sender_id, token) | build(t, sender_id, token)]
  end
end
