defmodule Servy do
  use Application

  def start(_type, _args) do
    IO.puts("Starting the application ...")
    {:ok, _sup_pid} = Servy.Supervisor.start_link()
  end
end
