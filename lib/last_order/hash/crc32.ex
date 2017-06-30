defmodule LastOrder.Hash.Crc32 do
  @doc """
  CRC32 hashing implementation.
  """
  def hash(s) when is_binary(s) do
    :erlang.crc32(s)
  end
  def hash({curr_hash, num}) when is_integer(curr_hash) and is_integer(num) do
    hash("#{curr_hash}#{num}")
  end
  def hash(blob) do
    hash(inspect(blob))
  end
end
