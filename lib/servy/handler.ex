defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests.
  """

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam
  alias Servy.Tracker
  alias Servy.Fetcher

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

  def route(conv = %Conv{method: "GET", path: "/sensors"}) do
    pid1 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-1") end)
    pid2 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-2") end)
    pid3 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-3") end)
    pid4 = Fetcher.async(fn -> Tracker.get_location("bigfoot") end)

    snapshot1 = Fetcher.get_result(pid1)
    snapshot2 = Fetcher.get_result(pid2)
    snapshot3 = Fetcher.get_result(pid3)
    bigfoot_location = Fetcher.get_result(pid4)

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{conv | status: 200, resp_body: inspect({snapshots, bigfoot_location})}
  end

  def route(conv = %Conv{method: "GET", path: "/snapshots"}) do
    pid1 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-1") end)
    pid2 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-2") end)
    pid3 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-3") end)

    snapshot1 = Fetcher.get_result(pid1)
    snapshot2 = Fetcher.get_result(pid2)
    snapshot3 = Fetcher.get_result(pid3)

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{conv | status: 200, resp_body: inspect(snapshots)}
  end

  def route(conv = %Conv{method: "GET", path: "/kaboom"}) do
    raise "Kaboom!"
    conv
  end

  def route(conv = %Conv{method: "GET", path: "/hibernate/" <> time}) do
    time |> String.to_integer() |> :timer.sleep()
    %{conv | status: 200, resp_body: "Awake!"}
  end

  def route(conv = %Conv{method: "GET", path: "/wildthings"}) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(conv = %Conv{method: "GET", path: "/bears"}) do
    BearController.index(conv)
  end

  def route(conv = %Conv{method: "GET", path: "/api/bears"}) do
    Servy.Api.BearController.index(conv)
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

  def format_response(conv = %Conv{resp_body: resp_body, resp_content_type: resp_content_type}) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: #{resp_content_type}
    Content-Length: #{String.length(resp_body)}
    
    #{resp_body}
    """
  end
end
