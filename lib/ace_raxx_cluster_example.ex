defmodule AceRaxxClusterExample do
  use Application

  @raxx_app {__MODULE__.Router, []}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = :erlang.binary_to_integer(System.get_env("PORT") || "8080")

    children = [
      worker(__MODULE__.Broadcast, [[name: __MODULE__.Broadcast]]),
      worker(__MODULE__.Tracker, [[name: __MODULE__.Tracker]]),
      worker(Ace.TCP, [{Raxx.Adapters.Ace.Handler, @raxx_app}, [port: port, name: __MODULE__.Web, acceptors: 5]])
    ]

    opts = [strategy: :one_for_one, name: Baobab.Web.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
