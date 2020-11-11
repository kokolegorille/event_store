defmodule EventStore.Core.Dispatcher do
  @moduledoc """
  The dispacther.
  It gets listeners from provider and send them the event,
  if the filtering function is true.
  """

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
