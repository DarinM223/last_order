defmodule LastOrder.Hash.Murmur do
  alias LastOrder.Hash.Murmur
  use Rustler, otp_app: :last_order, crate: "murmur"

  defstruct []

  defmodule NifNotLoaded, do: defexception message: "nif not loaded"

  def start_hash(_seed), do: err()
  def extend_hash(_hash, _value, _magic_a, _magic_b), do: err()
  def finalize_hash(_hash), do: err()
  def start_magic_a, do: err()
  def start_magic_b, do: err()
  def next_magic_a(_magic_a), do: err()
  def next_magic_b(_magic_b), do: err()
  def string_hash(_s), do: err()

  defp err(), do: throw NifNotLoaded

  defimpl LastOrder.Hash do
    def hash(_, s) when is_binary(s) do
      Murmur.string_hash(s)
    end
    def hash(type, blob) do
      hash(type, inspect(blob))
    end

    def extend(_, hash, num) when is_integer(hash) and is_integer(num) do
      h = Murmur.start_hash(hash)
      h = Murmur.extend_hash(h, num, Murmur.start_magic_a(), Murmur.start_magic_b())
      Murmur.finalize_hash(h)
    end
  end
end
