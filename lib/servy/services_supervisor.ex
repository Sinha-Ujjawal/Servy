defmodule Servy.ServicesSupervisor do
  use Supervisor

  defmodule State do
    @cache_size 3
    @refresh_interval 10
    defstruct cache_size: @cache_size, refresh_interval: @refresh_interval
  end

  def start_link(initial_config \\ %State{}) do
    IO.puts("Starting the services supervisor...")
    Supervisor.start_link(__MODULE__, initial_config, name: __MODULE__)
  end

  def init(%State{cache_size: cache_size, refresh_interval: refresh_interval}) do
    children = [
      {Servy.PledgeServer2, %{cache_size: cache_size}},
      {Servy.SensorServer, %{refresh_interval: refresh_interval}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
