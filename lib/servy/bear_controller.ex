defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear

  @templates_path Path.expand("../../templates", __DIR__)

  defp render(conv = %Conv{}, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{conv | status: 200, resp_body: content}
  end

  def index(conv = %Conv{}) do
    bears =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_brown/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.eex", bears: bears)
  end

  def show(conv = %Conv{}, _params = %{"id" => id}) do
    render(conv, "show.eex", bear: Wildthings.get_bear(id))
  end

  def create(conv = %Conv{}, _params = %{"type" => type, "name" => name}) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end
end
