defmodule EventStore.Repo do
  use Ecto.Repo,
    otp_app: :event_store,
    adapter: Ecto.Adapters.Postgres
end
