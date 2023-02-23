defmodule Olivia.Chat.Thinker do
  @moduledoc """
  Use a Olivia NLP API to determine which THINKER should be executed.
  """

  @default_nlp Application.compile_env(:olivia, :default_nlp)

  def call(nil), do: nil

  def call(message) do
    message
    |> module_nlp_thinking().call()
  end

  def module_api() do
    Module.concat(["Olivia", "Chat", "Thinker", nlp(), "Api"])
  end

  defp module_nlp_thinking do
    Module.concat(["Olivia", "Chat", "Thinker", nlp(), "Thinking"])
  end

  defp nlp() do
    Application.get_env(:olivia, :default_nlp)
    |> Macro.camelize
  end
end
