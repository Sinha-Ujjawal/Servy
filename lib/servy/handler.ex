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

    %{method: method, path: path, resp_body: "", status: nil}
  end

  def route(conv = %{method: method, path: path}), do: route(conv, method, path)

  def route(conv, "GET", "/wildthings") do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(conv, "GET", "/bears") do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(conv, _method, path) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(%{status: status, resp_body: resp_body}) do
    """
    HTTP/1.1 #{status} #{status_reason(status)}
    Content-Type: text/html
    Content-Length: #{String.length(resp_body)}
    
    #{resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "CREATED",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Interal Server Error"
    }[code]
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

# request3 = """
# GET /bigfoot HTTP/1.1
# HOST: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """
