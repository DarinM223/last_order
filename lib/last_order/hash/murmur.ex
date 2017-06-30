defmodule LastOrder.Hash.Murmur do
  @moduledoc """
  Implementation of Austin Appleby's MurmurHash algorithm.
  TODO(DarinM223): replace in favor of Rust NIF.
  """

  use Bitwise

  @visible_magic 0x971e137b
  @hidden_magic_a 0x95543787
  @hidden_magic_b 0x2ad7eb25
  @visible_mixer 0x52dce729
  @hidden_mixer_a 0x7b7d159c
  @hidden_mixer_b 0x6bce6396
  @final_mixer_1 0x85ebca6b
  @final_mixer_2 0xc2b2ae35
  @seed_string 0xf7ca7fd2

  def hash(s) when is_binary(s) do
    h = start_hash(byte_size(s) * @seed_string)
    c = @hidden_magic_a
    k = @hidden_magic_b
    limit_prec(_iter_hash(s, {h, c, k}))
  end

  defp _iter_hash(<<a :: size(8), b :: size(8), rest :: binary>>, {h, c, k}) do
    i = limit_prec(a <<< 16) + b
    h = extend_hash(h, i, c, k)

    if byte_size(rest) == 0 do
      finalize_hash(h)
    else
      c = next_magic_a(c)
      k = next_magic_b(k)
      _iter_hash(rest, {h, c, k})
    end
  end
  defp _iter_hash(<<a :: size(8)>>, {h, c, k}) do
    h = extend_hash(h, a, c, k)
    finalize_hash(h)
  end

  def start_hash(seed), do: seed ^^^ @visible_magic

  def start_magic_a, do: @hidden_magic_a
  def start_magic_b, do: @hidden_magic_b

  def next_magic_a(magic_a), do: magic_a * 5 + @hidden_mixer_a
  def next_magic_b(magic_b), do: magic_b * 5 + @hidden_mixer_b

  def extend_hash(hash, value, magic_a, magic_b) do
    (hash ^^^ rotl(value * magic_a, 11) * magic_b) * 3 + @visible_mixer
  end

  def finalize_hash(hash) do
    i = hash ^^^ limit_prec(hash >>> 16)
    i = i * @final_mixer_1
    i = i ^^^ limit_prec(i >>> 13)
    i = i * @final_mixer_2
    i = i ^^^ limit_prec(i >>> 16)
    i
  end

  defp rotl(l, shift) do
    limit_prec(l <<< shift ||| l >>> (64 - shift))
  end

  # Limits to 64 bits.
  defp limit_prec(num) do
    num &&& 0xFFFFFFFF
    # num &&& 0xFFFFFFFFFFFFFFFF
  end
end
