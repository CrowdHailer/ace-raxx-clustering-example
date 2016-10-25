defmodule AceRaxxClusterExample do
  defmodule Router do
    require EEx
    EEx.function_from_file :def, :home_page, "lib/ace_raxx_cluster_example/home_page.html.eex", [:nodes]

    def handle_request(%{path: []}, _) do
      {:ok, nodes} = AceRaxxClusterExample.Tracker.current
      body = home_page(nodes)
      Raxx.Response.ok(body, [{"content-length", "#{:erlang.iolist_size(body)}"}])
    end

    def handle_request(%{path: ["updates"]}, _) do
      GenEvent.add_handler(AceRaxxClusterExample.Broadcast, {AceRaxxClusterExample.BroadcastHandler, make_ref}, self)
      Raxx.ServerSentEvents.upgrade({__MODULE__, :noenv})
    end

    def handle_request(_, _) do
      Raxx.Response.not_found("not found")
    end

    def handle_info({:nodes, nodes}, _) do
      data = Enum.map(nodes, fn(n) -> n end) |> Enum.join("\", \"")
      event = Raxx.ServerSentEvents.Event.new("[\"#{data}\"]", event: "nodes")
      chunk = Raxx.ServerSentEvents.Event.to_chunk(event)
      {:chunk, chunk, :nostate}
    end
  end

  defmodule Tracker do
    use GenServer
    def start_link(opts) do
      GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
      all = :erlang.nodes
      for other <- all do
        :ok = :rpc.call(other, Tracker, :hello, [node])
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

  defmodule BroadcastHandler do
    use GenEvent

    def handle_event({:nodes, nodes}, connection) do
      send(connection, {:nodes, nodes})
      {:ok, connection}
    end
  end

  use Application

  @raxx_app {__MODULE__, []}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = :erlang.binary_to_integer(System.get_env("PORT")) || 8080

    children = [
      worker(GenEvent, [[name: __MODULE__.Broadcast]]),
      worker(__MODULE__.Tracker, [[name: __MODULE__.Tracker]]),
      worker(Ace.TCP, [{Raxx.Adapters.Ace.Handler, @raxx_app}, [port: port, name: __MODULE__.Web, acceptors: 5]])
    ]

    opts = [strategy: :one_for_one, name: Baobab.Web.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def handle_request(request, state) do
    Router.handle_request(request, state)
  end
end
