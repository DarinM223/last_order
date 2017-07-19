defmodule LastOrder.Hash.Crc32 do
  alias LastOrder.Hash.Crc32

  defstruct []

  defimpl LastOrder.Hash do
    def hash(_, s) when is_binary(s) do
      :erlang.crc32(s)
    end
    def hash(type, blob) do
      hash(type, inspect(blob))
    end

    def extend(type, curr_hash, num) do
      hash(type, "#{curr_hash}#{num}")
    end
  end
end
