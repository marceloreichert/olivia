defmodule Olivia.NLPMock do
  @moduledoc """
  """
  def get(message) do
    body =
      %{
        message: message,
        entities: %{
          intent: 'test',
          confidence: 1.0
        }
      }
      |> Jason.encode!()

    {:ok, %{body: body}}
  end
end
