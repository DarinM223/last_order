defmodule LastOrder.Router do
  use GenServer

  alias LastOrder.Ring
  alias LastOrder.Hash

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add(router, node) do
    GenServer.call(router, {:add, node})
  end

  def remove(router, node) do
    GenServer.call(router, {:remove, node})
  end

  def route(router, key) do
    GenServer.call(router, {:route, key})
  end

  def get(router) do
    GenServer.call(router, :get)
  end

  # GenServer API

  def init(:ok) do
    ring = Ring.new(&Hash.Crc32.hash/1)
    {:ok, {ring, []}}
  end

  def handle_call(:get, _from, {ring, _} = state) do
    {:reply, Ring.as_list(ring), state}
  end

  def handle_call({:add, node}, _from, {ring, refs}) do
    # TODO(DarinM223): handle duplicates
    ring = Ring.add(ring, node)
    refs = [{node, Process.monitor(node)} | refs]
    {:reply, :ok, {ring, refs}}
  end

  def handle_call({:remove, node}, _from, {ring, refs}) do
    ring = Ring.remove(ring, node)
    refs = List.keydelete(refs, node, 0)
    {:reply, :ok, {ring, refs}}
  end

  def handle_call({:route, key}, _from, {ring, _} = state) do
    {:reply, Ring.route(ring, key), state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {ring, refs}) do
    {node, _} = List.keyfind(refs, ref, 1)
    ring = Ring.remove(ring, node)
    refs = List.keydelete(refs, node, 0)
    {:noreply, {ring, refs}}
  end
end
