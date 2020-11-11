defmodule EventStore do
  @moduledoc """
  Documentation for `EventStore`.
  """

  alias __MODULE__.Core

  alias __MODULE__.Core.{
    Dispatcher,
    ListenersProvider
  }

  defdelegate create_event(dto), to: Core

  defdelegate list_events(criteria \\ []), to: Core

  defdelegate get_event(id), to: Core

  defdelegate max_global_position(), to: Core

  defdelegate dispatch(event), to: Dispatcher

  defdelegate register(pid, filter_fun \\ fn _ -> true end), to: ListenersProvider

  defdelegate unregister(pid), to: ListenersProvider

  defdelegate get_listeners, to: ListenersProvider
end
