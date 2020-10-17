defmodule EventStore.CoreTest do
  use EventStore.DataCase

  alias EventStore.Core
  alias EventStore.Core.Event

  @valid_attrs %{
    "stream_name"=>"gooogooo",
    "type"=>"test",
    "data"=>%{"fran"=>:wong},
    "metadata"=>%{"koko"=>:kiki}
  }

  describe "event auto increment fields" do
    test "it increments global position" do
      {:ok, %Event{global_position: gp1}} = Core.create_event(@valid_attrs)
      {:ok, %Event{global_position: gp2}} = Core.create_event(@valid_attrs)

      assert gp1 + 1 == gp2
    end

    test "it increments position, based on stream_name" do
      {:ok, %Event{position: p1}} = Core.create_event(@valid_attrs)
      {:ok, %Event{position: p2}} = Core.create_event(@valid_attrs)
      {:ok, %Event{position: p3}} = Core.create_event(%{@valid_attrs | "stream_name" => "mpoki"})

      assert p1 + 1 == p2
      assert p3 = 1
    end
  end
end
