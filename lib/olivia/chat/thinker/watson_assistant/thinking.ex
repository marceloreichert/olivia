defmodule Olivia.Chat.Thinker.WatsonAssistant.Thinking do
  @moduledoc """
  Thinking may use a Olivia NLP API to determine which routine the bot should execute.
  """
  require Logger

  alias Olivia.Chat.Thinker.WatsonAssistant.Api
  alias Olivia.Chat.Conversation

  def call(message) do
    message
    |> get_conversation_session
    |> think_and_answer
  end

  defp get_conversation_session(%{sender_id: sender_id} = message) do
    with state <- Conversation.get_session(sender_id) do
      with %{session_id: session_id} <- state do
        session_id
        |> (&Map.merge(message, %{session_id: &1})).()
      end
    end
  end

  defp think_and_answer(%{text: text, session_id: session_id} = message) do
    with {:ok, response} <- Api.think_and_answer(session_id, text) do
      case response do
        %{code: 404, error: error} ->
          Map.merge(message, %{responses: [
            %{
              options: [
                %{label: "start", value: %{input: %{text: "Recomeçar"}}}
              ],
              response_type: "option",
              title: "Sessão inválida"
            }
          ]})

        _ ->
          response
          |> get_output(message)
          |> get_context(response)
      end
    end
  end

  defp get_output(%{output: output} = response, message) do
    with %{entities: entities, intents: intents, generic: responses} <- output do
      message
      |> add_responses(responses)
      |> add_intents(intents)
      |> add_entities(entities)
    end
  end

  defp get_context(message, %{context: %{skills: %{"main skill": %{user_defined: context}}}} = response) do
    message
    |> add_context(context)
  end
  defp get_context(message, _) do
    message
  end

  defp add_context(message, user_defined) do
    user_defined
    |> (&Map.merge(message, %{context: &1})).()
  end

  defp add_responses(message, responses) do
    responses
    |> (&Map.merge(message, %{responses: &1})).()
  end

  defp add_intents(message, intents) do
    intents
    |> (&Map.merge(message, %{intents: &1})).()
  end

  defp add_entities(message, entities) do
    entities
    |> (&Map.merge(message, %{entities: &1})).()
  end

  defp get_session(%{body: watson_response}) do
    watson_response
    |> Jason.decode!
    |> Map.fetch!("session_id")
  end
end
