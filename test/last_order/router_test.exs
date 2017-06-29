defmodule RouterTest do
  use ExUnit.Case, async: true

  alias LastOrder.Router
  alias LastOrder.Testing
  alias LastOrder.Hash

  setup context do
    {:ok, router} = Router.start_link
    {:ok, _} = Testing.DummyWorker.start_link(name: context.test)
    {:ok, router: router, worker: context.test}
  end

  test "adds pid to the router", %{router: router, worker: worker} do
    Router.add(router, worker)
    assert Router.get(router) == [worker]
  end

  test "removes pid from the router", %{router: router, worker: worker} do
    Router.add(router, worker)
    Router.remove(router, worker)
    assert Router.get(router) == []
  end

  test "removes pid on process kill", %{router: router, worker: worker} do
    Router.add(router, worker)

    ref = Process.monitor(worker)
    GenServer.stop(worker)
    assert_receive {:DOWN, ^ref, _, _, _}

    assert Router.get(router) == []
  end
end
