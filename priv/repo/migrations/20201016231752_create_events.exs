defmodule EventStore.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :stream_name, :string, null: false
      add :type, :string, null: false
      add :position, :bigint, default: 0
      add :global_position, :bigserial, null: false
      add :data, :map
      add :metadata, :map
      add :expected_version, :bigint

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:events, [:global_position])
    create index(:events, [:stream_name])
    create index(:events, [:type])
  end
end
