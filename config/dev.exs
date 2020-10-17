import Config

config :event_store, EventStore.Repo,
  database: "event_store_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10
