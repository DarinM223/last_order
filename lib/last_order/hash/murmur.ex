defmodule LastOrder.Hash.Murmur do
  use Rustler, otp_app: :last_order, crate: "murmur"

  defmodule NifNotLoaded, do: defexception message: "nif not loaded"

  @doc """
  MurmurHash hashing implementation.
  """
  def hash(s) when is_binary(s) do
    string_hash(s)
  end
  def hash(blob) do
    hash(inspect(blob))
  end

  def start_hash(_seed), do: err()
  def extend_hash(_hash, _value, _magic_a, _magic_b), do: err()
  def finalize_hash(_hash), do: err()
  def start_magic_a, do: err()
  def start_magic_b, do: err()
  def next_magic_a(_magic_a), do: err()
  def next_magic_b(_magic_b), do: err()
  def string_hash(_s), do: err()

  defp err() do
     throw NifNotLoaded
  end
end
