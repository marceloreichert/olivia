defmodule Olivia.Chat.Conversation do
  @moduledoc """
  GenServer to maintain conversation state
  """

  use GenServer
  require Logger

  alias Olivia.Chat.Conversation.Supervisor

  defmodule State do
    @moduledoc false
    @environment Application.get_env(:olivia, :environment)

    defstruct [
      :sender_id,
      :last_recieved_at,
      :messages,
      :pid,
      :session_id,
      environment: @environment
    ]
  end

  @type state :: %State{}
  @type sender_id :: String.t()

  # five minutes timeout
  @timeout 5 * 60 * 1000
  @default_nlp Application.get_env(:olivia, :default_nlp)

  def start_link(sender_id) do
    GenServer.start_link(__MODULE__, sender_id, name: pid(sender_id))
  end

  def pid(sender_id) do
    {:via, Registry, {Olivia.Chat.Conversation.Registry, sender_id}}
  end

  def received_message(%{sender_id: sender_id} = impression) do
    ensure_process(sender_id)
    GenServer.cast(pid(sender_id), {:received, impression})
    impression
  end

  def sent_message(sender_id, response) do
    ensure_process(sender_id)
    GenServer.cast(pid(sender_id), {:sent, response})
  end

  def get_session(sender_id) do
    ensure_process(sender_id)
    GenServer.call(pid(sender_id), :get_session)
  end

  def ensure_process(sender_id) do
    case Registry.whereis_name({Olivia.Chat.Conversation.Registry, sender_id}) do
      :undefined -> Supervisor.start_child(sender_id)
      _ -> :ok
    end
  end

  def terminate(sender_id) do
    GenServer.call(pid(sender_id), :terminate)
  end


  # GENSERVER
  def init(sender_id) do
    Logger.info("Starting conversation for #{sender_id}")

    self()
    |> schedule_timeout()

    state = %State{
      last_recieved_at: Timex.now(),
      messages: [],
      pid: pid(sender_id),
      sender_id: sender_id,
      session_id: set_session_id(sender_id)
    }
    Logger.info("Starting conversation with state #{state}")

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

  defp schedule_timeout(pid) do
    Logger.debug(fn -> "Scheduling timeout for #{inspect(pid)}" end)
    :erlang.send_after(@timeout, pid, :timeout)
  end

  defp set_session_id(sender_id) do
    case @default_nlp do
      :none -> String.to_integer(sender_id)
      _ ->  with thinking_api <- Olivia.Chat.Thinker.module_api() do
              case thinking_api.create_session do
                {:ok, %{body: body} = response} ->
                  body
                  |> Jason.decode!
                  |> Map.fetch!("session_id")
                {:undefined} -> sender_id
              end
            end
    end
  end
end
