defmodule Servy.Handler do
  def handle(request) do
    # conv = parse(request)
    # conv = route(conv)
    # format_response(conv)
    request
    |> parse
    |> log
    |> route
    |> format_response
  end

  def log(data), do: IO.inspect(data)

  def parse(request) do
    [method, path, _version] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, path: path, resp_body: ""}
  end

  def route(conv = %{path: path}), do: route(conv, path)

  def route(conv, "/wildthings") do
    %{conv | resp_body: "Bears, Lions, Tigers"}
  end

  def route(conv, "/bears") do
    %{conv | resp_body: "Teddy, Smokey, Paddington"}
  end

  def format_response(%{resp_body: resp_body}) do
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{String.length(resp_body)}
    
    #{resp_body}
    """
  end
end

# # The Black line is important
# request = """
# GET /wildthings HTTP/1.1
# HOST: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# request2 = """
# GET /bears HTTP/1.1
# HOST: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """
