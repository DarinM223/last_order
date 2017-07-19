defmodule RingTest do
  use ExUnit.Case, async: true
  doctest LastOrder.Ring

  test "adding server adds virtual nodes" do
    ring = LastOrder.Ring.new(%LastOrder.Hash.Murmur{}, 5)
    assert LastOrder.Ring.add(ring, "hello") ==
      {{5,
        {3863517872, "hello",
         {1282032160, "hello",
          {221236529, "hello", nil,
           {1265930077, "hello", {679480565, "hello", nil, nil}, nil}},
          nil}, nil}}, %LastOrder.Hash.Murmur{}, 5}
  end

  test "removing server removes virtual nodes" do
    ring = LastOrder.Ring.new(%LastOrder.Hash.Murmur{}, 5)
    ring = LastOrder.Ring.add(ring, "hello")
    assert LastOrder.Ring.remove(ring, "hello") ==
      {{0, nil}, %LastOrder.Hash.Murmur{}, 5}
  end
end
