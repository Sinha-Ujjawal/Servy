defmodule Servy.Handler do
  def handle(request) do
    # conv = parse(request)
    # conv = route(conv)
    # format_response(conv)
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> format_response
  end

  def rewrite_path(conv = %{path: "/wildlife"}) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

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

  def route(conv, "GET", "/bears/" <> bear_id) do
    case bear_id
         |> String.to_integer()
         |> get_bear_by_id do
      {:ok, bear} ->
        %{conv | status: 200, resp_body: bear}

      {:error, reason} ->
        %{conv | status: 404, resp_body: reason}
    end
  end

  def route(conv, _method, path) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def get_bear_by_id(id) do
    case id do
      1 -> {:ok, "Teddy"}
      2 -> {:ok, "Smokey"}
      3 -> {:ok, "Paddington"}
      _ -> {:error, "No bear with id: #{id}"}
    end
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

Enum.each(
  [
    """
    GET /wildthings HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    
    """,
    """
    GET /bears HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    
    """,
    """
    GET /bigfoot HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    
    """,
    """
    GET /bears/1 HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    
    """,
    """
    GET /bears/100 HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    
    """,
    """
    GET /wildlife HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    
    """
  ],
  fn request ->
    request |> Servy.Handler.handle() |> IO.puts()
  end
)
