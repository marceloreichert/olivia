defmodule Olivia.Chat.Thinker do
  @moduledoc """
  Use a Olivia NLP API to determine which THINKER should be executed.
  """

  @default_nlp Application.get_env(:olivia, :default_nlp)

  def run(impression) do
    impression
    |> module_nlp_thinking().run
  end

  def module_nlp_thinking do
    Module.concat(["Olivia", "Chat", "Thinker", nlp, "Thinking"])
  end

  def module_api do
    Module.concat(["Olivia", "Chat", "Thinker", nlp, "Api"])
  end

  defp nlp do
    @default_nlp
    |> Atom.to_string
    |> Macro.camelize
  end
end
