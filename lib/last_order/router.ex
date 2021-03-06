defmodule LastOrder.Router do
  use GenServer

  alias LastOrder.Ring
  alias LastOrder.Hash.Murmur

  def start_link(nodes, v_nodes, opts \\ []) do
    GenServer.start_link(__MODULE__, {nodes, v_nodes}, opts)
  end

  def add(router, node) do
    GenServer.call(router, {:add, node})
  end

  def remove(router, node) do
    GenServer.call(router, {:remove, node})
  end

  def route(router, key, args, call_fn \\ &GenServer.call/2) do
    GenServer.call(router, {:route, key, args, call_fn})
  end

  def get(router) do
    GenServer.call(router, :get)
  end

  # GenServer API

  def init({nodes, v_nodes}) do
    ring = Ring.new(%Murmur{}, v_nodes)
    {ring, refs} = Enum.reduce(nodes, {ring, []}, fn(node, state) ->
      add_node(state, node)
    end)
    {:ok, {ring, refs}}
  end

  def handle_call(:get, _from, {ring, _} = state) do
    {:reply, Ring.as_list(ring), state}
  end

  def handle_call({:add, node}, _from, state) do
    {:reply, :ok, add_node(state, node)}
  end

  def handle_call({:remove, node}, _from, state) do
    {:reply, :ok, remove_node(state, node)}
  end

  def handle_call({:route, key, args, call_fn}, _from, {ring, _} = state) do
    {:reply, Ring.route(ring, key, args, call_fn), state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {_, refs} = state) do
    {node, _} = List.keyfind(refs, ref, 1)
    {:noreply, remove_node(state, node)}
  end

  defp add_node({ring, refs}, node) do
    ring = Ring.add(ring, node)
    refs = [{node, Process.monitor(node)} | refs]
    {ring, refs}
  end

  defp remove_node({ring, refs}, node) do
    ring = Ring.remove(ring, node)
    refs = List.keydelete(refs, node, 0)
    {ring, refs}
  end
end
