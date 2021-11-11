defmodule Servy.PledgeServer2 do
  @name :pledge_server

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # Client Interface
  def start(cache_size \\ 3) do
    IO.puts("Starting the pledge server...")
    GenServer.start(__MODULE__, %State{cache_size: cache_size}, name: @name)
  end

  def create_pledge(name, amount), do: GenServer.call(@name, {:create_pledge, name, amount})

  def recent_pledges(), do: GenServer.call(@name, :recent_pledges)

  def total_pledged(), do: GenServer.call(@name, :total_pledged)

  def clear(), do: GenServer.cast(@name, :clear)

  def set_cache_size(new_size), do: GenServer.cast(@name, {:set_cache_size, new_size})

  # Server Callbacks
  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    {:ok, %{state | pledges: Enum.take(pledges, state.cache_size)}}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    new_pledges = [{name, amount} | most_recent_pledges]
    {:reply, id, %{state | pledges: new_pledges}}
  end

  def handle_call(:recent_pledges, _from, state), do: {:reply, state.pledges, state}

  def handle_call(:total_pledged, _from, state) do
    total =
      state.pledges
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()

    {:reply, total, state}
  end

  def handle_cast(:clear, state), do: {:noreply, %{state | pledges: []}}

  def handle_cast({:set_cache_size, new_size}, state) do
    {:noreply, %{state | cache_size: new_size, pledges: Enum.take(state.pledges, new_size)}}
  end

  def handle_info(message, state) do
    IO.puts("Can't touch this! #{inspect(message)}")
    {:noreply, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FROM EXTERNAL SERVICE

    # Example return value:
    [{"wilma", 15}, {"fred", 25}]
  end
end

# alias Servy.PledgeServer2

# {:ok, pid} = PledgeServer2.start(100)

# # handle_info is called for unexpected messages
# # default implementation just logs an error,
# # but this can be overrided via handle_info
# send(pid, {:stop, "hammertime"})

# IO.inspect(PledgeServer2.create_pledge("larry", 10))
# # PledgeServer2.clear()
# IO.inspect(PledgeServer2.create_pledge("moe", 20))
# IO.inspect(PledgeServer2.create_pledge("curly", 30))
# IO.inspect(PledgeServer2.create_pledge("daisy", 40))
# # PledgeServer2.set_cache_size(4)
# IO.inspect(PledgeServer2.create_pledge("grace", 50))
# IO.inspect(PledgeServer2.recent_pledges())
# IO.inspect(PledgeServer2.total_pledged())
