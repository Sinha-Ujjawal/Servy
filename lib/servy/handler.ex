defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests.
  """

  alias Servy.Conv
  alias Servy.BearController

  @pages_path "../../pages" |> Path.expand(__DIR__)

  import Servy.Parser, only: [parse: 1]
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]

  @doc "Transforms the request into a response"
  def handle(request) do
    # conv = parse(request)
    # conv = route(conv)
    # format_response(conv)
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def route(conv = %Conv{method: "GET", path: "/wildthings"}) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(conv = %Conv{method: "GET", path: "/bears"}) do
    BearController.index(conv)
  end

  def route(conv = %Conv{method: "GET", path: "/bears/" <> id, params: params}) do
    BearController.show(conv, Map.put(params, "id", id))
  end

  def route(conv = %Conv{method: "POST", path: "/bears", params: params}) do
    BearController.create(conv, params)
  end

  # def route(conv = %Conv{method: "GET", path: "/about"}) do
  #   about_file =
  #     "../../pages"
  #     |> Path.expand(__DIR__)
  #     |> Path.join("about.html")

  #   case File.read(about_file) do
  #     {:ok, contents} ->
  #       %{conv | status: 200, resp_body: contents}

  #     {:error, :enoent} ->
  #       %{conv | status: 500, resp_body: "File not found!"}

  #     {:error, reason} ->
  #       %{conv | status: 500, resp_body: "File error: #{reason}"}
  #   end
  # end

  def route(conv = %Conv{method: "GET", path: "/about"}) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(conv = %Conv{method: method, path: path}) do
    %{conv | status: 404, resp_body: "No #{method} #{path} here!"}
  end

  def handle_file({:ok, content}, conv = %Conv{}) do
    %{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv = %Conv{}) do
    %{conv | status: 500, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv = %Conv{}) do
    %{conv | status: 500, resp_body: "File error: #{reason}"}
  end

  def format_response(conv = %Conv{resp_body: resp_body}) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(resp_body)}

    #{resp_body}
    """
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

    """,
    """
    GET /about HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    POST /bears HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 21

    name=Baloo&type=Brown
    """
  ],
  fn request ->
    request |> Servy.Handler.handle() |> IO.puts()
  end
)
