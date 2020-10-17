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

      timestamps(type: :utc_datetime)
    end
  end
end
