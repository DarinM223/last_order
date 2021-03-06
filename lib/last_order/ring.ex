defmodule LastOrder.Ring do
  @moduledoc """
  Simple implementation of a consistent hash ring using
  Erlang's built in balanced tree library.
  """

  alias LastOrder.Hash

  @doc """
  Creates a new ring.

  ## Example

      iex> LastOrder.Ring.new(%LastOrder.Hash.Crc32{})
      {{0, nil}, %LastOrder.Hash.Crc32{}, 1}

      iex> LastOrder.Ring.new(%LastOrder.Hash.Murmur{}, 4)
      {{0, nil}, %LastOrder.Hash.Murmur{}, 4}

  """
  def new(hash_type, v_nodes \\ 1) do
    {:gb_trees.empty(), hash_type, v_nodes}
  end

  @doc """
  Adds a server to the ring.

  ## Example

      iex> ring = LastOrder.Ring.new(%LastOrder.Hash.Crc32{})
      iex> LastOrder.Ring.add(ring, "hello")
      {{1, {2534913988, "hello", nil, nil}}, %LastOrder.Hash.Crc32{}, 1}

  """
  def add({tree, hash_type, v_nodes}, value) do
    hash = Hash.hash(hash_type, value)
    tree = Enum.reduce(1..v_nodes, tree, fn(v_node, tree) ->
      hash = Hash.extend(hash_type, hash, v_node)
      :gb_trees.insert(hash, value, tree)
    end)
    {tree, hash_type, v_nodes}
  end

  @doc """
  Removes a server from the ring.

  ## Example

      iex> ring = LastOrder.Ring.new(%LastOrder.Hash.Crc32{})
      iex> ring = LastOrder.Ring.add(ring, "hello")
      iex> LastOrder.Ring.remove(ring, "hello")
      {{0, nil}, %LastOrder.Hash.Crc32{}, 1}

  """
  def remove({tree, hash_type, v_nodes}, value) do
    hash = Hash.hash(hash_type, value)
    tree = Enum.reduce(1..v_nodes, tree, fn(v_node, tree) ->
      hash = Hash.extend(hash_type, hash, v_node)
      :gb_trees.delete(hash, tree)
    end)
    {tree, hash_type, v_nodes}
  end

  @doc """
  Routes a call to the correct node.

  ## Example

      iex> LastOrder.TestHelpers.DummyWorker.start_link(name: :dummy)
      iex> ring = LastOrder.Ring.new(%LastOrder.Hash.Crc32{})
      iex> ring = LastOrder.Ring.add(ring, :dummy)
      iex> LastOrder.Ring.route(ring, "hello", :get)
      :dummy
      iex> LastOrder.Ring.route(ring, "hello", :get, &GenServer.call/2)
      :dummy

  """
  def route(ring, value, args, call_fn \\ &GenServer.call/2) do
    location = find_best_match(ring, value)
    call_fn.(location, {:route, args})
  end

  @doc """
  Returns the location of the best matching server
  in the ring.

  ## Example

      iex> ring = LastOrder.Ring.new(%LastOrder.Hash.Crc32{}) |>
      ...> LastOrder.Ring.add("foo@localhost") |>
      ...> LastOrder.Ring.add("bar@localhost")
      iex> LastOrder.Ring.find_best_match(ring, "http://www.twitter.com")
      "foo@localhost"
      iex> LastOrder.Ring.find_best_match(ring, "http://www.twitter.com/careers")
      "bar@localhost"

  """
  def find_best_match({tree, hash_type, _}, value) do
    hash = Hash.hash(hash_type, value)
    iter =
      case :gb_trees.iterator_from(hash, tree) do
        [] -> :gb_trees.iterator(tree)
        iter -> iter
      end

    {_, location, _} = :gb_trees.next(iter)
    location
  end

  @doc """
  Returns the tree as a list.

  ## Example

      iex> ring = LastOrder.Ring.new(%LastOrder.Hash.Crc32{})
      iex> ring = LastOrder.Ring.add(ring, "foo@localhost")
      iex> ring = LastOrder.Ring.add(ring, "bar@localhost")
      iex> LastOrder.Ring.as_list(ring)
      ["foo@localhost", "bar@localhost"]

  """
  def as_list({tree, _, _}) do
    iter = :gb_trees.iterator(tree)
    _iter(iter, [])
  end

  defp _iter(iter, result) do
    case :gb_trees.next(iter) do
      {_, location, iter} -> _iter(iter, [location | result])
      :none -> result
    end
  end
end
