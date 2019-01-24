defmodule Olivia.DispatcherTest do
  use ExUnit.Case

  alias Olivia.FbMessenger.Dispatcher

  test "send_messenger_response/0" do
    assert Dispatcher.send_messenger_response([]) == []
  end

  describe "send_messenger_response/1" do
  end
end
