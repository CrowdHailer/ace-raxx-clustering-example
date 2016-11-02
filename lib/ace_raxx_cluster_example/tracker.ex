defmodule AceRaxxClusterExample.Tracker do
  use GenServer
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, socket} = :gen_udp.open(8383, [
      :binary,
      broadcast: true,
      active: true,
      ip: {0,0,0,0}
    ])

    # Broadcast hello to the entire network.
    # This is done only once as the node doesn't need to contact new nodes.
    # New nodes will contact the cluster when they come up.
    :ok = :gen_udp.send(socket, {10, 10, 10, 255}, 8383, "ADD ME")

    {:ok, MapSet.new}
  end

  def hello(other) do
    GenServer.call(__MODULE__, {:hello, other})
  end

  def current() do
    GenServer.call(__MODULE__, :current)
  end

  # When a node makes contact it needs to be monitored and added to the set.
  def handle_call({:hello, other}, _from, nodes) do
    :erlang.monitor_node(other, true)
    nodes = MapSet.put(nodes, other)
    GenEvent.notify(AceRaxxClusterExample.Broadcast, {:nodes, MapSet.put(nodes, node())})
    {:reply, :ok, nodes}
  end

  # Get the set of all nodes the tracker is currently aware of.
  def handle_call(:current, _from, nodes) do
    {:reply, {:ok, MapSet.put(nodes, node())}, nodes}
  end

  # All nodes are monitored.
  # When a node becomes unresponsive it needs to be removed from the set of nodes.
  # Once removed the updated set is broadcast.
  def handle_info({:nodedown, other}, nodes) do
    nodes = MapSet.delete(nodes, other)
    GenEvent.notify(AceRaxxClusterExample.Broadcast, {:nodes, MapSet.put(nodes, node())})
    {:noreply, nodes}
  end

  # When a broadcast is recieved, the node will try and connect.
  # An rpc call makes sure that the node is also running a tracker and belongs in the set.
  def handle_info({:udp, _socket, ip, 8383, "ADD ME"}, nodes) do
    {a, b, c, d} = ip
    other = :"example@#{a}.#{b}.#{c}.#{d}"
    if other != node do
      :ok = :rpc.call(other, __MODULE__, :hello, [node])
      :erlang.monitor_node(other, true)
      nodes = MapSet.put(nodes, other)
      GenEvent.notify(AceRaxxClusterExample.Broadcast, {:nodes, MapSet.put(nodes, node())})
    end
    {:noreply, nodes}
  end
end
