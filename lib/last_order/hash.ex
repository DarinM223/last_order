defprotocol LastOrder.Hash do
  @moduledoc """
  Protocol for converting values
  into number hashes.
  """

  @doc """
  Hashes a value into a number.
  Should work on all types by converting the type
  into a binary string.
  """
  def hash(hash_type, value)

  @doc """
  Extends an existing hash with an additional number.
  """
  def extend(hash_type, hash, num)
end
