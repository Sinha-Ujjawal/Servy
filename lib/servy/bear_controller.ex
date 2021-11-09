defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear

  defp bear_item(bear), do: "<li>#{bear.name} - #{bear.type}</li>"

  def index(conv = %Conv{}) do
    items =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_brown/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)
      |> Enum.map(&bear_item/1)
      |> Enum.join("\n")

    %{conv | status: 200, resp_body: "<ul>#{items}</ul>"}
  end

  def show(conv = %Conv{}, _params = %{"id" => id}) do
    case Wildthings.get_bear(id) do
      nil ->
        %{conv | status: 404, resp_body: "No bear with id: #{id}"}

      bear ->
        %{conv | status: 200, resp_body: bear.name}
    end
  end

  def create(conv = %Conv{}, _params = %{"type" => type, "name" => name}) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end
end
