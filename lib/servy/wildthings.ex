defmodule Servy.Wildthings do
  alias Servy.Bear

  def list_bears do
    [
      %Bear{id: 1, name: "Teddy", type: "Brown", hibernating: true},
      %Bear{id: 2, name: "Smokey", type: "Black"},
      %Bear{id: 3, name: "Paddington", type: "Brown"}
    ]
  end

  def get_bear(id) when is_integer(id) do
    list_bears()
    |> Enum.find(fn bear -> bear.id == id end)
  end

  def get_bear(id) when is_binary(id), do: get_bear(String.to_integer(id))
end
