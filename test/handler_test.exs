defmodule HandlerTest do
  use ExUnit.Case
  doctest Servy.Handler
  import Servy.Handler, only: [handle: 1]

  test "GET/wildthings" do
    request = """
    GET /wildthings HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = handle(request)

    assert response == """
           HTTP/1.1 200 OK
           Content-Type: text/html
           Content-Length: 20

           Bears, Lions, Tigers
           """
  end
end
