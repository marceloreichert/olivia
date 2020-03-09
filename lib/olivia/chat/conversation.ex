defmodule Olivia.Chat.Conversation do
  @moduledoc """
  GenServer to maintain conversation state
  """

  use GenServer
  require Logger

  alias Olivia.Chat.Conversation.Supervisor

  @registry :conversations_registry

  defmodule State do
    @moduledoc false

    defstruct [
      :sender_id,
      :last_recieved_at,
      :pid,
      :session_id,
      :messages
    ]
  end

  # API
  def start_link(sender_id) do
    GenServer.start_link(__MODULE__, sender_id, name: get_pid(sender_id))
  end

  def received_message(%{sender_id: sender_id} = impression) do
    Supervisor.start_child(sender_id)
    GenServer.cast(get_pid(sender_id), {:received, impression})
    impression
  end

  def sent_message(sender_id, response) do
    GenServer.cast(get_pid(sender_id), {:sent, response})
  end

  def get_session(sender_id) do
    GenServer.call(get_pid(sender_id), :get_session)
  end

  # GENSERVER
  def init(sender_id) do
    Logger.info("Starting conversation for #{sender_id}")

    state = %State{
      last_recieved_at: Timex.now(),
      messages: [],
      pid: get_pid(sender_id),
      sender_id: sender_id,
      session_id: set_session_id(sender_id)
    }

    {:ok, state}
  end

  def handle_cast({:received, payload}, state) do
    Logger.info("Received a message for #{state.sender_id}")

    new_state =
      state
      |> Map.put(:last_recieved_at, Timex.now())
      |> Map.put(:messages, [payload | state.messages])

    {:noreply, new_state}
  end

  def handle_cast({:sent, response}, state) do
    Logger.info("Sent a message to #{state.sender_id}")

    new_state =
      state
      |> Map.put(:messages, [response | state.messages])

    {:noreply, new_state}
  end

  def handle_call(:terminate, _from, state) do
    Logger.info("Terminating process: #{inspect(state)}")

    {:stop, :normal, :ok, state}
  end

  def handle_call(:get_session, from, %{session_id: session_id} = state) do
    {:reply, state, state}
  end

  defp get_pid(sender_id) do
    {:via, Registry, {@registry, sender_id}}
  end

  defp set_session_id(sender_id) do
    case Application.get_env(:olivia, :default_nlp) do
      :none -> String.to_integer(sender_id)
      _ ->  with thinking_api <- Olivia.Chat.Thinker.module_api() do
              case thinking_api.create_session do
                {:ok, %{body: body} = response} ->
                  session_id =
                    body
                    |> Jason.decode!
                    |> Map.fetch!("session_id")
                {:undefined} -> sender_id
              end
            end
    end
  end
end
