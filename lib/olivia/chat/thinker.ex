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
    Module.concat(["Olivia","Chat","Thinker",nlp,"Thinking"])
  end

  def module_api do
    Module.concat(["Olivia","Chat","Thinker",nlp,"Api"])
  end

  defp nlp do
    @default_nlp
    |> Atom.to_string
    |> Macro.camelize
  end

  @doc """
  Matches messages based on the regular expression.

  ## Example

      hear ~r/hello/, msg do
        # code to handle the message
      end
  """
  defmacro hear(regex, msg, state \\ Macro.escape(%{}), do: block) do
    name = unique_name(:hear)
    quote do
      @hear {unquote(regex), unquote(name)}
      @doc false
      def unquote(name)(unquote(msg), unquote(state)) do
        unquote(block)
      end
    end
  end

  @doc """
  Send a reply message via the underlying adapter.

  ## Example

      reply msg, "Hello there!"
  """
  def reply(%Hedwig.Message{robot: robot} = msg, text) do
    Hedwig.Robot.reply(robot, %{msg | text: text})
  end

  defp unique_name(type) do
    String.to_atom("#{type}_#{System.unique_integer([:positive, :monotonic])}")
  end

end
