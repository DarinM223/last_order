defmodule LastOrder.Hash.Crc32 do
  @doc """
  CRC32 hashing implementation.
  """
  def hash(s) when is_binary(s) do
    :erlang.crc32(s)
  end
  def hash(blob) do
    hash(inspect(blob))
  end
end
