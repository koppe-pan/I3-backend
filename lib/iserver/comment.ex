defmodule Iserver.Comment do
  @derive {Jason.Encoder, only: [:content, :time]}
  defstruct commented_by: nil, content: nil, time: nil

  def create(%{user_id: user_id, content: content}) do
    %__MODULE__{commented_by: user_id, content: content, time: System.system_time(:milisecond)}
  end
end
