defmodule Servy.HttpServer do
  @doc """
  Starts the server on the given `port` of localhost.
  """
  def start(port) when is_integer(port) and port > 1023 do
    # created a socket to listen for the client connections.
    # `listen_socket` is bound to the listening socket.
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    # Socket options (don't worry about these details):
    # `:binary` -- open the socket in "binary" model and deliver data as binaries
    # `packet: :raw` -- deliver the entire binary without doing any packet handling
    # `active: false` -- receive data when we're ready by calling `:gen_tcp.recv/2`
    # `reuseaddr: true` -- allows reusing the address if the listener crashes or drops

    IO.puts("\n🎧 Listening for the connection requests on port #{port}...\n")

    accept_loop(listen_socket)
  end

  @doc """
  Accepts client connections on the `listen_socket`.
  """
  def accept_loop(listen_socket) do
    IO.puts("⌛ Waiting to accept a client connection...\n")

    # Suspends (blocks) and waits for a client connection. When a connection
    # is accepted, `client_socket` is bound to a new client socket.
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts("⚡ Connection accepted\n")

    # Receives the request and sends a response over the client socket. (In a new process)
    spawn(fn -> serve(client_socket) end)

    # Look back to wait and accept the next connection.
    accept_loop(listen_socket)
  end

  @doc """
  Receives the request on `client_socket` and
  sends a response back over the same socket.
  """
  def serve(client_socket) do
    IO.puts("#{inspect(self())}: Working on it!")

    client_socket
    |> read_request
    |> Servy.Handler.handle()
    # |> generate_response
    |> write_response(client_socket)
  end

  @doc """
  Receives a socket on the `client_socker`
  """
  def read_request(client_socket) do
    # 0 denotes all available bytes
    {:ok, request} = :gen_tcp.recv(client_socket, 0)

    IO.puts("➡ Received request:\n")
    IO.puts(request)

    request
  end

  @doc """
  Returns a generic HTTP repose.
  """
  def generate_response(_request) do
    """
    HTTP/1.1 200 OK
    Content-Type: text/plain
    Content-Length: 6
    
    Hello!
    """
  end

  @doc """
  Sends the `response` over the `client_socket`
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts("⬅ Sent response:\n")
    IO.puts(response)

    # Closes the client socket, ending the connection.
    # Does not close the listen socket!
    :gen_tcp.close(client_socket)
  end

  # gen_tcp server example:- https://www.erlang.org/doc/man/gen_tcp.html
  # server() ->
  #   {ok, LSock} = gen_tcp:listen(5678, [binary, {packet, 0},
  #                                       {active, false}]),
  #   {ok, Sock} = gen_tcp:accept(LSock),
  #   {ok, Bin} = do_recv(Sock, []),
  #   ok = gen_tcp:close(Sock),
  #   ok = gen_tcp:close(LSock),
  #   Bin.

  def server do
    {:ok, lsock} = :gen_tcp.listen(5678, [:binary, packet: 0, active: false])
    {:ok, sock} = :gen_tcp.accept(lsock)
    {:ok, bin} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)
    :ok = :gen_tcp.close(lsock)

    # request data
    bin
  end
end
