defmodule EventStore.Core.ListenersProvider do
  @moduledoc """
  The listener provider.
  A simple gen server managing an ets table. It stores pid, filter_fun, and ref.
  It monitors clients and update ets table.
  """

  use GenServer
  require Logger

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(@name, nil, name: @name)
  end

  def register(pid, filter_fun \\ fn _ -> true end)

  def register(pid, filter_fun) when is_function(filter_fun) do
    GenServer.call(@name, {:register, pid, filter_fun})
  end

  def unregister(pid) do
    GenServer.cast(@name, {:unregister, pid})
  end

  def get_listeners do
    @name
    |> :ets.match_object({:"$1", :"$2", :_})
    |> Enum.map(fn {pid, filter_fun, _ref} -> {pid, filter_fun} end)
  end

  def stop, do: GenServer.cast(@name, :stop)

  @impl GenServer
  def init(_) do
    Logger.debug(fn -> "#{@name} is starting}" end)
    #
    Process.flag(:trap_exit, true)
    :ets.new(@name, [:set, :protected, :named_table])
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:register, pid, filter_fun}, _from, _state) do
    ref = Process.monitor(pid)
    :ets.insert_new(@name, {pid, filter_fun, ref})
    {:reply, :ok, nil}
  end

  @impl GenServer
  def handle_cast({:unregister, pid}, _state) do
    case :ets.match(@name, {pid, :_, :"$1"}) do
      [[ref]] when is_reference(ref) -> Process.demonitor(ref)
      _ -> nil
    end

    :ets.delete(@name, pid)

    {:noreply, nil}
  end

  @impl GenServer
  def handle_cast(:stop, _state), do: {:stop, :normal, nil}

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, pid, _status}, _state) do
    :ets.delete(@name, pid)
    {:noreply, nil}
  end

  @impl GenServer
  def terminate(reason, _state) do
    Logger.debug(fn -> "#{@name} is stopping : #{inspect(reason)}" end)
    #
    :ets.delete(@name)
    :ok
  end
end
