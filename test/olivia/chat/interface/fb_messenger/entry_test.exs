defmodule Olivia.Chat.Interface.FbMessenger.EntryTest do
  use ExUnit.Case

  alias Olivia.Chat.Interface.FbMessenger.Entry

  @message [
    %{
      "id" => "217_557_272_146_428",
      "messaging" => [
        %{
          "message" => %{
            "mid" => "MementoMoriId",
            "seq" => 60_729,
            "text" => "yo"
          },
          "recipient" => %{"id" => "TEST_RECIPIENT"},
          "sender" => %{"id" => "TEST_SENDER"},
          "timestamp" => 1_533_595_043_166
        }
      ],
      "time" => 1_533_595_072_532
    }
  ]

  describe "process_messages/1" do
    test "" do
      Entry.process_messages(@message)
    end
  end

  describe "start_typing_indicator/1" do
  end

  describe "stop_typing_indicator/1" do
  end
end
