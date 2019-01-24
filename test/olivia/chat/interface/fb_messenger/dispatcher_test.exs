defmodule Olivia.DispatcherTest do
  use ExUnit.Case

  alias Olivia.Chat.Interface.FbMessenger.Dispatcher

  test "send_response/0" do
    assert Dispatcher.send_response([]) == []
  end

  describe "send_response/1" do
  end
end
