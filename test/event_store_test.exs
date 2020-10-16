defmodule EventStoreTest do
  use ExUnit.Case
  doctest EventStore

  test "greets the world" do
    assert EventStore.hello() == :world
  end
end
