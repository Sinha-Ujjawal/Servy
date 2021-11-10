defmodule Servy.Api.BearController do
  alias Servy.Conv
  alias Servy.Wildthings

  def index(conv = %Conv{}) do
    bears_json = Wildthings.list_bears() |> Jason.encode!()
    %{conv | status: 200, resp_body: bears_json, resp_content_type: "application/json"}
  end
end
