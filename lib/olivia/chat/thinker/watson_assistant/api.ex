defmodule Olivia.Chat.Thinker.WatsonAssistant.Api do
  @moduledoc """
    IBM Watson Assistant AI integration for intent handling and NLP
  """

  @doc """
  Requests a session ID from Watson Assistant.
  """
  def create_session do
    config = configs()

    url =
      config.assistant_endpoint
      |> _append_to_url(config.assistance_api_version)
      |> _append_to_url("assistants")
      |> _append_to_url(config.assistant_id)
      |> _append_to_url("sessions")
      |> create_url(config.options |> hd |> elem(1))

    {:ok, _response} = HTTPoison.post(url, [], config.headers)
  end

  @doc """
  Delete a session ID from Watson Assistant.
  """
  def delete_session(session_id) do
    config = configs()

    url =
      config.assistant_endpoint
      |> _append_to_url(config.assistance_api_version)
      |> _append_to_url("assistants")
      |> _append_to_url(config.assistant_id)
      |> _append_to_url("sessions")
      |> _append_to_url("#{session_id}")
      |> create_url(config.options |> hd |> elem(1))

    {:ok, _response} = HTTPoison.delete(url, [], config.headers)
  end

  @doc """
  Requests a Watson Assistant AI NLP analysis. Returns a response object.
  """
  def think_and_answer(session_id, text) do
    config = configs()

    url =
      config.assistant_endpoint
      |> _append_to_url(config.assistance_api_version)
      |> _append_to_url("assistants")
      |> _append_to_url(config.assistant_id)
      |> _append_to_url("sessions")
      |> _append_to_url("#{session_id}")
      |> _append_to_url("message")
      |> create_url(config.options |> hd |> elem(1))

    options = %{
      debug: false,
      restart: false,
      alternate_intents: false,
      return_context: true
    }

    input = %{
      message_type: "text",
      text: text,
      options: options
    }

    body = Jason.encode!(%{input: input})

    {:ok, _response} =
      HTTPoison.post(url, body, config.headers)
      |> case do
        {:ok, %{body: raw, status_code: _code}} -> {:ok, raw}
        {:error, %{reason: reason}} -> {:error, reason}
      end
      |>  (fn {_code, body} ->
        body
        |> Jason.decode(keys: :atoms)
        |> case do
             {:ok, parsed} -> {:ok, parsed}
             _ -> {:error, body}
           end
         end).()
  end

  # Creates a request URL according to Wit specs
  defp create_url(endpoint, %{} = params) do
    params
    |> Map.keys()
    |> Enum.reverse()
    |> Enum.reduce(endpoint, fn key, url ->
      _append_to_url(url, key, Map.get(params, key))
    end)
  end

  defp _append_to_url(url, _method), do: "#{url}/#{_method}"
  defp _append_to_url(url, _key, ""), do: url
  defp _append_to_url(url, key, param), do: "#{url}?#{key}=#{param}"

  defp configs() do
    %{
      assistant_endpoint: Application.get_env(:olivia, :watson_assistant_endpoint),
      assistance_api_version: Application.get_env(:olivia, :watson_assistant_api_version),
      assistance_params_version: Application.get_env(:olivia, :watson_assistant_params_version),
      assistant_apikey: Application.get_env(:olivia, :watson_assistant_apikey),
      assistant_id: Application.get_env(:olivia, :watson_assistant_id),
      options: [
        params: %{
          "version" => Application.get_env(:olivia, :watson_assistant_params_version)
        }
      ],
      headers: [
        "Authorization": "Basic " <> Base.encode64("apikey:" <> Application.get_env(:olivia, :watson_assistant_apikey, "")),
        "Accept": "Application/json; Charset=utf-8",
        "Content-Type": "application/json"
      ]
    }
  end
end
