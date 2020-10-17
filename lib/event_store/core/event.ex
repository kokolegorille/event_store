defmodule EventStore.Core.Event do
  use Ecto.Schema

  @timestamps_opts type: :utc_datetime
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field(:stream_name, :string)
    field(:type, :string)
    field(:position, :integer, default: 0)
    field(:global_position, :integer, read_after_writes: true)
    field(:data, :map)
    field(:metadata, :map)
    field(:expected_version, :integer, default: 0)

    timestamps()
  end
end
