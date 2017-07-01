defmodule LastOrder do
  @moduledoc """
  A distributed router that uses consistent hashing
  to route messages to different nodes based on a hashable value.
  """

  def start(_type, _args) do
    LastOrder.Supervisor.start_link
  end
end
