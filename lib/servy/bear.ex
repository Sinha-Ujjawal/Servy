defmodule Servy.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  def is_brown(%Servy.Bear{type: type}), do: type == "Brown"

  def order_asc_by_name(bear1 = %Servy.Bear{}, bear2 = %Servy.Bear{}),
    do: bear1.name <= bear2.name
end
