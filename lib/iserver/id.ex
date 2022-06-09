defmodule Iserver.ID do
  def sha256(data) do
    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
  end
end
