defmodule LastOrder.Supervisor do
  use Supervisor

  @v_nodes Application.get_env(:last_order, :v_nodes)
  @nodes Application.get_env(:last_order, :nodes)

  def start_link(router_name \\ LastOrder.Router, opts \\ []) do
    Supervisor.start_link(__MODULE__, router_name, opts)
  end

  def init(router_name) do
    children = [
      worker(LastOrder.Router, [@nodes, @v_nodes, [name: router_name]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
