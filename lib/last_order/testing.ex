defmodule LastOrder.Testing do
  defmodule DummyWorker do
    use GenServer

    def start_link(opts \\ []) do
      GenServer.start_link(__MODULE__, opts[:name], opts)
    end

    def init(name) do
      {:ok, name}
    end

    def handle_call({:route, :get}, _from, name) do
      {:reply, name, name}
    end
  end
end
