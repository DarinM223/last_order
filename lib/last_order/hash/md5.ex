defmodule LastOrder.Hash.Md5 do
  @doc """
  MD5 hashing implementation.
  """
  def hash(s) when is_binary(s) do
    :crypto.hash(:md5, s)
  end
  def hash(blob) do
    hash(inspect(blob))
  end
end
