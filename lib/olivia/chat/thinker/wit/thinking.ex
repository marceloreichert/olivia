defmodule Olivia.Chat.Thinker.Wit.Thinking do

  alias Olivia.Chat.Thinker.Wit.Api

  def run(impression) do
    impression
    |> maybe_get_entities
    |> maybe_get_intents
  end

  def maybe_get_entities(%{intent: _intent} = impression), do: impression
  def maybe_get_entities(%{message: message, sender_id: sender_id} = impression) do
    with {:ok, response} <- Api.get(message) do
      response
      |> gets_entities
      |> (&Map.merge(impression, %{entities: &1})).()
    end
  end

  defp gets_entities(%{body: watson_response}) do
    watson_response
    |> Jason.decode!()
    |> Map.fetch("entities")
    |> elem(1)
  end

  def maybe_get_intents(impression) do
    impression
    |> get_most_likely_intent()
    |> Map.merge(impression)
  end

  defp get_most_likely_intent(impression) do
    impression
  end
end
