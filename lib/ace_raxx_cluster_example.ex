defmodule AceRaxxClusterExample do
  defmodule Router do
    def handle_request(_, _) do
      body = "Hello, World!"
      Raxx.Response.ok(body)
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

    def handle_call({:hello, other}, _from, nodes) do
      :erlang.monitor_node(other, true)
      nodes = MapSet.put(nodes, other)
      GenEvent.notify(AceRaxxClusterExample.Broadcast, {:nodes, nodes})
      {:reply, :ok, nodes}
    end

    def handle_info({:nodedown, other}, nodes) do
      nodes = MapSet.delete(nodes, other)
      GenEvent.notify(AceRaxxClusterExample.Broadcast, {:nodes, nodes})
      {:noreply, nodes}
    end
  end

  defmodule BroadcastHandler do
    use GenEvent

    def handle_event({:nodes, nodes}, connection) do
      send(connection, nodes)
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
    response = Router.handle_request(request, state)
    headers = response.headers ++ [{"content-length", "#{:erlang.iolist_size(response.body)}"}]
    %{response | headers: headers}
  end
end
