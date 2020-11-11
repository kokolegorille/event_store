# EventStore

A simple Event Store written in Elixir.

It has an event dispatcher, where it is possible to un/register. 
You can add a filtering function, to select which events to listen to.

It uses Ecto 3.5, with postgresql.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `event_store` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:event_store, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/event_store](https://hexdocs.pm/event_store).

