defmodule Servy.HttpServer do
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
