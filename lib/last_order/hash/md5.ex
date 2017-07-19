defmodule LastOrder.Hash.Md5 do
  alias LastOrder.Hash.Md5

  defstruct []

  defimpl LastOrder.Hash do
    def hash(_, s) when is_binary(s) do
      :crypto.hash(:md5, s)
    end
    def hash(type, blob) do
      hash(type, inspect(blob))
    end

    def extend(type, curr_hash, num) do
      hash(type, "#{curr_hash}#{num}")
    end
  end
end
