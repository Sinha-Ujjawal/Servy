defmodule Servy.Handler do
  def handle(request) do
    # conv = parse(request)
    # conv = route(conv)
    # format_response(conv)
    request
    |> parse
    |> route
    |> format_response
  end

  def parse(request) do
    [method, path, _version] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, path: path, resp_body: ""}
  end

  def route(conv) do
    # TODO: Create a new map that also has the response body:
    conv = %{method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers"}
  end

  def format_response(conv) do
    # TODO: Use values in the map to create a HTTP response string:
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20
    
    Bears, Lions, Tigers
    """
  end
end

# The Black line is important
request = """
GET /wildthings HTTP/1.1
HOST: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts(response)
