defmodule AceRaxxClusterExample.Router do
  require EEx
  EEx.function_from_file :def, :home_page, "lib/ace_raxx_cluster_example/home_page.html.eex", [:nodes]

  def handle_request(%{path: []}, _) do
    {:ok, nodes} = AceRaxxClusterExample.Tracker.current
    body = home_page(nodes)
    Raxx.Response.ok(body, [{"content-length", "#{:erlang.iolist_size(body)}"}])
  end

  def handle_request(%{path: ["updates"]}, _) do
    GenEvent.add_handler(AceRaxxClusterExample.Broadcast, {AceRaxxClusterExample.Broadcast, make_ref}, self)
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

  defp link_href(node) do
    [name, ip] =String.split("#{node}", "@")
    "http://#{ip}:8080"
  end
end
