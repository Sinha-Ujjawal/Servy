defmodule HandlerTest do
  use ExUnit.Case
  doctest Servy.Handler
  import Servy.Handler, only: [handle: 1]

  test "GET /wildthings" do
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

  test "GET /bears" do
    request = """
    GET /bears HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 93

    <ul>

        <li>Paddington - Brown</li>

        <li>Teddy - Brown</li>

    </ul>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /bigfoot" do
    request = """
    GET /bigfoot HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = handle(request)

    assert response == """
           HTTP/1.1 404 Not Found
           Content-Type: text/html
           Content-Length: 21

           No GET /bigfoot here!
           """
  end

  test "GET /bears/1" do
    request = """
    GET /bears/1 HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 38

    <h1>Show Bear</h1>
    <p>
    Teddy
    </p>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /bears/100" do
    request = """
    GET /bears/100 HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 56

    <h1>Show Bear</h1>
    <p>
    "Bear does not exists!"
    </p>

    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "GET /wildlife" do
    request = """
    GET /wildlife HTTP/1.1
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

  test "GET /about" do
    request = """
    GET /about HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 328

    <h1>Clark's Wildthings Refuge</h1>

    <blockquote>
    When we contemplate the whole globe as one great dewdrop, striped and dotted
    with continents and islands, flying through space with other stars all singing
    and shining together as one, the whole universe appears as an infinite storm
    of beauty. -- John Muir
    </blockquote>
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "POST /bears" do
    request = """
    POST /bears HTTP/1.1
    HOST: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 21

    name=Baloo&type=Brown
    """

    response = handle(request)

    assert response == """
           HTTP/1.1 201 CREATED
           Content-Type: text/html
           Content-Length: 33

           Created a Brown bear named Baloo!
           """
  end

  def remove_whitespace(s) do
    String.replace(s, ~r{\s}, "")
  end
end
