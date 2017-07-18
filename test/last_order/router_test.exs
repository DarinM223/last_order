defmodule RouterTest do
  use ExUnit.Case, async: true

  alias LastOrder.Router
  alias LastOrder.TestHelpers.DummyWorker

  setup context do
    {:ok, test: context.test}
  end

  test "adds pid to the router", %{test: worker} do
    {:ok, router} = Router.start_link([], 1)
    {:ok, _} = DummyWorker.start_link(name: worker)
    Router.add(router, worker)
    assert Router.get(router) == [worker]
  end

  test "removes pid from the router", %{test: worker} do
    {:ok, router} = Router.start_link([], 1)
    {:ok, _} = DummyWorker.start_link(name: worker)
    Router.add(router, worker)
    Router.remove(router, worker)
    assert Router.get(router) == []
  end

  test "removes pid on process kill", %{test: worker} do
    {:ok, router} = Router.start_link([], 1)
    {:ok, _} = DummyWorker.start_link(name: worker)
    Router.add(router, worker)

    ref = Process.monitor(worker)
    GenServer.stop(worker)
    assert_receive {:DOWN, ^ref, _, _, _}

    assert Router.get(router) == []
  end

  test "adds passed in nodes", %{test: test} do
    names = Enum.map(1..4, &(:"#{test}_#{&1}"))
    Enum.each(names, &DummyWorker.start_link(name: &1))
    {:ok, router} = Router.start_link(names, 4)
    assert length(Router.get(router)) == 4 * length(names)
  end

  test "routes to worker", %{test: worker} do
    {:ok, router} = Router.start_link([], 1)
    {:ok, _} = DummyWorker.start_link(name: worker)
    Router.add(router, worker)

    assert Router.route(router, "hello", :get) == worker
  end
end
