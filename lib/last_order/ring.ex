defmodule LastOrder.Ring do
  @moduledoc """
  Simple implementation of a consistent hash ring using
  Erlang's built in balanced tree library.
  """

  @doc """
  Creates a new ring.

  ## Example

      iex> LastOrder.Ring.new(&LastOrder.Hash.Crc32.hash/1)
      {{0, nil}, &LastOrder.Hash.Crc32.hash/1, 1}

      iex> LastOrder.Ring.new(&LastOrder.Hash.Murmur.hash/1, 4)
      {{0, nil}, &LastOrder.Hash.Murmur.hash/1, 4}

  """
  def new(hash_fn, v_nodes \\ 1) do
    {:gb_trees.empty(), hash_fn, v_nodes}
  end

  @doc """
  Adds a server to the ring.

  ## Example

      iex> ring = LastOrder.Ring.new(&LastOrder.Hash.Crc32.hash/1)
      iex> LastOrder.Ring.add(ring, "hello")
      {{1, {2534913988, "hello", nil, nil}}, &LastOrder.Hash.Crc32.hash/1, 1}

      iex> ring = LastOrder.Ring.new(&LastOrder.Hash.Murmur.hash/1, 5)
      iex> LastOrder.Ring.add(ring, "hello")
      {{5,
        {1378021531, "hello", {328213002, "hello", nil, nil},
         {3431377204, "hello", {2855951083, "hello", nil, nil},
          {4064065953, "hello", nil, nil}}}},
        &LastOrder.Hash.Murmur.hash/1, 5}

  """
  def add({tree, hash_fn, v_nodes}, value) do
    hash = hash_fn.(value)
    tree = Enum.reduce(1..v_nodes, tree, fn(v_node, tree) ->
      hash = hash_fn.({hash, v_node})
      :gb_trees.insert(hash, value, tree)
    end)
    {tree, hash_fn, v_nodes}
  end

  @doc """
  Removes a server from the ring.

  ## Example

      iex> ring = LastOrder.Ring.new(&LastOrder.Hash.Crc32.hash/1)
      iex> ring = LastOrder.Ring.add(ring, "hello")
      iex> LastOrder.Ring.remove(ring, "hello")
      {{0, nil}, &LastOrder.Hash.Crc32.hash/1, 1}

      iex> ring = LastOrder.Ring.new(&LastOrder.Hash.Murmur.hash/1, 5)
      iex> ring = LastOrder.Ring.add(ring, "hello")
      iex> LastOrder.Ring.remove(ring, "hello")
      {{0, nil}, &LastOrder.Hash.Murmur.hash/1, 5}

  """
  def remove({tree, hash_fn, v_nodes}, value) do
    hash = hash_fn.(value)
    tree = Enum.reduce(1..v_nodes, tree, fn(v_node, tree) ->
      hash = hash_fn.({hash, v_node})
      :gb_trees.delete(hash, tree)
    end)
    {tree, hash_fn, v_nodes}
  end

  @doc """
  Routes a call to the correct node.
  """
  def route(ring, value) do
    location = find_best_match(ring, value)
    raise "Not implemented"
  end

  @doc """
  Returns the location of the best matching server
  in the ring.

  ## Example

      iex> ring = LastOrder.Ring.new(&LastOrder.Hash.Crc32.hash/1) |>
      ...> LastOrder.Ring.add("foo@localhost") |>
      ...> LastOrder.Ring.add("bar@localhost")
      iex> LastOrder.Ring.find_best_match(ring, "http://www.twitter.com")
      "foo@localhost"
      iex> LastOrder.Ring.find_best_match(ring, "http://www.twitter.com/careers")
      "bar@localhost"

  """
  def find_best_match({tree, hash_fn, _}, value) do
    hash = hash_fn.(value)
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

      iex> ring = LastOrder.Ring.new(&LastOrder.Hash.Crc32.hash/1)
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
