import Config

config :event_store,
  ecto_repos: [EventStore.Repo]

config :event_store, EventStore.Repo, migration_primary_key: [name: :id, type: :binary_id]

config :postgrex, :json_library, Jason

import_config "#{Mix.env()}.exs"
