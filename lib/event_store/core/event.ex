defmodule EventStore.Core.Event do
  @moduledoc """
  The event schema.
  """

  use Ecto.Schema

  # No need for update_at, as it is append only mode.
  @timestamps_opts type: :utc_datetime, updated_at: false
  @primary_key {:id, :binary_id, autogenerate: true}

  # No need for foreign key type...
  #@foreign_key_type :binary_id
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
