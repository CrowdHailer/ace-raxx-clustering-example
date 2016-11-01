defmodule AceRaxxClusterExample.Broadcast do
  use GenEvent

  def start_link(options) do
    GenEvent.start_link(options)
  end

  ## CALLBACKS

  def handle_event({:nodes, nodes}, connection) do
    send(connection, {:nodes, nodes})
    {:ok, connection}
  end
end
