defmodule Signature do
  @doc """
  Get the first n bytes of a file for signature tests.
  """
  def first_bytes(path, n) do
    data = File.read!(path)
    first_n_bytes = binary_part(data, 0, n)
    :erlang.binary_to_list(first_n_bytes)
  end
end
