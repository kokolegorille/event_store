defmodule EventStore.Core.Dispatcher do
  require Logger

  alias EventStore.Core.ListenersProvider

  def dispatch(event) do
    Logger.info("DISPATCH EVENT : #{inspect(event)}")

    ListenersProvider.get_listeners()
    |> Enum.filter(fn {_pid, filter_fun} -> filter_fun.(event) end)
    |> Enum.each(fn {pid, _apply_fun} -> send(pid, event) end)
    :ok
  end
end
