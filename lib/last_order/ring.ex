defmodule LastOrder.Ring do
  @moduledoc """
  Simple implementation of a consistent hash ring using
  Erlang's built in balanced tree library.
  """

  @doc """
  Creates a new ring.

  ## Example

      iex> LastOrder.Ring.new(&LastOrder.Hash.Crc32.hash/1)
      {{0, nil}, &LastOrder.Hash.Crc32.hash/1}

  """
  def new(hash_fn) do
    {:gb_trees.empty(), hash_fn}
  end

  @doc """
  Adds a server to the ring.

  ## Example

      iex> ring = LastOrder.Ring.new(&LastOrder.Hash.Crc32.hash/1)
      iex> LastOrder.Ring.add(ring, "hello")
      {{1, {907060870, "hello", nil, nil}}, &LastOrder.Hash.Crc32.hash/1}

  """
  def add({tree, hash_fn}, value) do
    hash = hash_fn.(value)
    {:gb_trees.insert(hash, value, tree), hash_fn}
  end

  @doc """
  Removes a server from the ring.

  ## Example

      iex> ring = LastOrder.Ring.new(&LastOrder.Hash.Crc32.hash/1)
      iex> ring = LastOrder.Ring.add(ring, "hello")
      iex> LastOrder.Ring.remove(ring, "hello")
      {{0, nil}, &LastOrder.Hash.Crc32.hash/1}

  """
  def remove({tree, hash_fn}, value) do
    hash = hash_fn.(value)
    {:gb_trees.delete(hash, tree), hash_fn}
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
      "bar@localhost"
      iex> LastOrder.Ring.find_best_match(ring, "http://www.twitter.com/feed")
      "foo@localhost"

  """
  def find_best_match({tree, hash_fn}, value) do
    hash = hash_fn.(value)
    iter =
      case :gb_trees.iterator_from(hash, tree) do
        [] -> :gb_trees.iterator(tree)
        iter -> iter
      end

    {_, location, _} = :gb_trees.next(iter)
    location
  end
end
