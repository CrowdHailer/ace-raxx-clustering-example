defmodule AceRaxxClusterExample.Tracker do
  use GenServer
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    all = :erlang.nodes
    for other <- all do
      :ok = :rpc.call(other, __MODULE__, :hello, [node])
      :erlang.monitor_node(other, true)
    end
    nodes = MapSet.new(all)
    GenEvent.notify(AceRaxxClusterExample.Broadcast, {:nodes, nodes})
    {:ok, nodes}
  end

  def hello(other) do
    GenServer.call(__MODULE__, {:hello, other})
  end

  def current() do
    GenServer.call(__MODULE__, :current)
  end

  def handle_call({:hello, other}, _from, nodes) do
    :erlang.monitor_node(other, true)
    nodes = MapSet.put(nodes, other)
    GenEvent.notify(AceRaxxClusterExample.Broadcast, {:nodes, MapSet.put(nodes, node())})
    {:reply, :ok, nodes}
  end

  def handle_call(:current, _from, nodes) do
    {:reply, {:ok, MapSet.put(nodes, node())}, nodes}
  end

  def handle_info({:nodedown, other}, nodes) do
    nodes = MapSet.delete(nodes, other)
    GenEvent.notify(AceRaxxClusterExample.Broadcast, {:nodes, MapSet.put(nodes, node())})
    {:noreply, nodes}
  end
end
