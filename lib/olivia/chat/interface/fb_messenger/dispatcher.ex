defmodule Olivia.Chat.Interface.FbMessenger.Dispatcher do
  @moduledoc """
  Dispatcher messages
  """

  @headers [{"Content-Type", "application/json"}]

  def send_response([]), do: []

  def send_response([h | t]) do
    [send_response(h) | send_response(t)]
  end

  def send_response(response) do
    token = Application.get_env(:olivia, :fb_page_access_token, "")
    url = "https://graph.facebook.com/v16.0/me/messages?access_token=#{token}"

    case HTTPoison.post(url, Jason.encode!(response), @headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        # Conversation.sent_message(response)
        :ok

      error ->
        IO.inspect(error)
        error
    end
  end

  def build_response(nil), do: nil

  def build_response(%{responses: responses, sender_id: sender_id} = message) do
    responses
    |> Enum.map(fn response ->
      prepare_response(response, sender_id)
    end)

    message
  end

  def prepare_response(%{response_type: "text", text: text} = _response, sender_id) do
    %{
      "messaging_type" => "RESPONSE",
      "recipient" => %{"id" => sender_id},
      "message" => %{
        "text" => text
      }
    }
    |> send_response()
  end

  def prepare_response(%{response_type: "list", options: options} = _response, sender_id) do
    elements =
      options
      |> Enum.map(fn %{title: title, subtitle: subtitle, image_url: image_url, url: url} ->
        %{
          "title" => title,
          "image_url" => image_url,
          "subtitle" => subtitle,
          "default_action" => %{
            "type" => "web_url",
            "url" => url,
            "messenger_extensions" => false,
            "webview_height_ratio" => "tall"
          }
        }
      end)

    %{
      "recipient" => %{"id" => sender_id},
      "message" => %{
        "attachment" => %{
          "type" => "template",
          "payload" => %{
            "template_type" => "generic",
            "elements" => elements
          }
        }
      }
    }
    |> send_response()
  end

  def prepare_response(%{response_type: "option", title: title, options: options} = _response, sender_id) do
    buttons =
      options
      |> Enum.map(fn %{label: label, value: %{input: %{text: text}}} = _option ->
        %{
          "type" => "postback",
          "title" => text,
          "payload" => label
        }
      end)

    elements =
      %{
        "title" => title,
        "buttons" => buttons
      }

    %{
      "recipient" => %{"id" => sender_id},
      "message" => %{
        "attachment" => %{
          "type" => "template",
          "payload" => %{
            "template_type" => "generic",
            "elements" => [elements]
          }
        }
      }
    }
    |> send_response()
  end
end
