defmodule LastOrder.Router do
  use GenServer

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

  # GenServer API

  def init(:ok) do
    ring = LastOrder.Ring.new(&LastOrder.Hash.Crc32.hash/1)
    {:ok, {ring, []}}
  end

  def handle_call({:add, node}, _from, {ring, refs}) do
    ring = LastOrder.Ring.add(ring, node)
    {:reply, :ok, {ring, refs}}
  end

  def handle_call({:remove, node}, _from, {ring, refs}) do
    ring = LastOrder.Ring.remove(ring, node)
    {:reply, :ok, {ring, refs}}
  end

  def handle_call({:route, key}, _from, {ring, _} = state) do
    result = LastOrder.Ring.route(ring, key)
    {:ok, result, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {ring, refs}) do
    # TODO(DarinM223): remove node from refs
    # LastOrder.Ring.remove(ring, node)
  end
end
