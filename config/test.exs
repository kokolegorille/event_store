import Config

config :event_store, EventStore.Repo,
  database: "event_store_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
