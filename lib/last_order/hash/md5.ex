defmodule LastOrder.Hash.Md5 do
  @doc """
  MD5 hashing implementation.
  """
  def hash(s) do
    :crypto.hash(:md5, s)
  end
end
