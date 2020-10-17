defmodule EventStore.MixProject do
  use Mix.Project

  def project do
    [
      app: :event_store,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {EventStore.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.5"},
      {:ecto_sql, "~> 3.5"},
      {:postgrex, "~> 0.15.6"},
      {:jason, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  # This makes sure your factory and any other modules in test/support are compiled
  # when in the test environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
