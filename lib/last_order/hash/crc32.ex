defmodule LastOrder.Hash.Crc32 do
  @doc """
  CRC32 hashing implementation.
  """
  def hash(s) do
    :erlang.crc32(s)
  end
end
