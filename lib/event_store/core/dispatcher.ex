defmodule EventStore.Core.Dispatcher do
  alias EventStore.Core.ListenersProvider

  def dispatch(event) do
    ListenersProvider.get_listeners()
    |> Enum.filter(fn {_pid, filter_fun} -> filter_fun.(event) end)
    |> Enum.each(fn {pid, _apply_fun} -> send(pid, event) end)
    :ok
  end
end
