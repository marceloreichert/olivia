defmodule Olivia.Chat.Thinker.WatsonAssistant.Thinking do
  @moduledoc """
  Thinking may use a Olivia NLP API to determine which routine the bot should execute.
  """
  require Logger

  alias Olivia.Chat.Thinker.WatsonAssistant.Api
  alias Olivia.Chat.Conversation

  def run(impression) do
    impression
    |> get_conversation_session
    |> think_and_answer
  end

  defp get_conversation_session(%{sender_id: sender_id} = impression) do
    with state = Conversation.get_session(sender_id) do
      with %{session_id: session_id} = state do
        session_id
        |> (&Map.merge(impression, %{session_id: &1})).()
      end
    end
  end

  defp think_and_answer(%{message: message, session_id: session_id} = impression) do
    with {:ok, response} <- Api.think_and_answer(session_id, message) do
      response
      |> get_output(impression)
      |> get_context(response)
    end
  end

  defp get_output(%{output: output} = response, impression) do
    with %{entities: entities, intents: intents} <- output do
      impression
      |> add_responses(%{output: output})
      |> add_intents(intents)
      |> add_entities(entities)
    end
  end

  defp get_context(impression, %{context: %{skills: %{"main skill": %{user_defined: context}}}} = response) do
    impression
    |> add_context(context)
  end
  defp get_context(impression, _) do
    impression
  end

  defp add_context(impression, user_defined) do
    user_defined
    |> (&Map.merge(impression, %{context: &1})).()
  end

  defp add_responses(impression, responses) do
    responses
    |> (&Map.merge(impression, %{responses: &1})).()
  end

  defp add_intents(impression, intents) do
    intents
    |> (&Map.merge(impression, %{intents: &1})).()
  end

  defp add_entities(impression, entities) do
    entities
    |> (&Map.merge(impression, %{entities: &1})).()
  end

  defp get_session(%{body: watson_response}) do
    watson_response
    |> Jason.decode!
    |> Map.fetch!("session_id")
  end
end
