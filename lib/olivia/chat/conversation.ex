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
      :last_received_at,
      :pid,
      :session_id,
      :messages,
      :intent,
      :entity,
      :context,
      :responses,
      :metadata
    ]
  end

  # API
  def start_link(sender_id) do
    GenServer.start_link(__MODULE__, sender_id, name: get_pid(sender_id))
  end

  def received_message(nil), do: nil

  def received_message(%{sender_id: sender_id} = message) do
    Supervisor.start_child(sender_id)

    :timer.sleep(3_000)

    GenServer.call(get_pid(sender_id), {:received, message})

    message
  end

  def sent_message(%{"recipient" => %{"id" => sender_id}} = message) do
    GenServer.cast(get_pid(sender_id), {:sent, message})
    message
  end

  def set_state(sender_id, message) do
    GenServer.cast(get_pid(sender_id), {:set_state, message})
  end

  def set_intent(sender_id, value) do
    GenServer.cast(get_pid(sender_id), {:set_intent, value})
  end

  def set_entity(sender_id, value) do
    GenServer.cast(get_pid(sender_id), {:set_entity, value})
  end

  def set_metadata(sender_id, value) do
    GenServer.cast(get_pid(sender_id), {:set_metadata, value})
  end

  def get_session(sender_id) do
    GenServer.call(get_pid(sender_id), :get_session)
  end

  # GENSERVER
  def init(sender_id) do
    Logger.info("Starting conversation for #{sender_id}")

    state = %State{
      last_received_at: Timex.now(),
      messages: [],
      pid: get_pid(sender_id),
      sender_id: sender_id,
      session_id: set_session_id(sender_id),
      metadata: %{}
    }

    {:ok, state}
  end

  def handle_info(:long_init, state) do
    :timer.sleep(3_000)

    {:no_reply, state}
  end


  def handle_call({:received, message}, _from, state) do
    Logger.info("Received a message for #{state.sender_id}")

    new_state =
      state
      |> Map.put(:last_recieved_at, Timex.now())
      |> Map.put(:messages, [message | state.messages])

    {:reply, new_state, state}
  end

  def handle_call(:terminate, _from, state) do
    Logger.info("Terminating process: #{inspect(state)}")

    {:stop, :normal, :ok, state}
  end

  def handle_call(:get_session, _from, %{session_id: _session_id} = state) do
    {:reply, state, state}
  end

  def handle_cast({:sent, _message}, state) do
    Logger.info("Sent a message to #{state.sender_id}")

    {:noreply, state}
  end

  def handle_cast({:set_state, value}, state) do
    new_state =
      state
      |> Map.put(:metadata, value)

    {:noreply, new_state}
  end

  def handle_cast({:set_intent, value}, state) do
    new_state =
      state
      |> Map.put(:intent, value)

    {:noreply, new_state}
  end

  def handle_cast({:set_entity, value}, state) do
    new_state =
      state
      |> Map.put(:entity, value)

    {:noreply, new_state}
  end

  def handle_cast({:set_metadata, value}, state) do
    new_state =
      state
      |> Map.put(:metadata, value)

    {:noreply, new_state}
  end

  defp get_pid(sender_id) do
    {:via, Registry, {@registry, sender_id}}
  end

  defp set_session_id(sender_id) do
    case Application.get_env(:olivia, :default_nlp) do
      :none -> String.to_integer(sender_id)
      _ ->  with thinking_api <- Olivia.Chat.Thinker.module_api() do
              case thinking_api.create_session do
                {:ok, %{body: body} = _response} ->
                  body
                  |> Jason.decode!
                  |> Map.fetch!("session_id")

                {:undefined} ->
                  sender_id
              end
            end
    end
  end
end
