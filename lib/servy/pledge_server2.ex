defmodule Servy.PledgeServer2 do
  @name :pledge_server

  use GenServer

  # Client Interface
  def start do
    IO.puts("Starting the pledge server...")
    GenServer.start(__MODULE__, [], name: @name)
  end

  def create_pledge(name, amount), do: GenServer.call(@name, {:create_pledge, name, amount})

  def recent_pledges(), do: GenServer.call(@name, :recent_pledges)

  def total_pledged(), do: GenServer.call(@name, :total_pledged)

  def clear(), do: GenServer.cast(@name, :clear)

  # Server Callbacks
  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {:reply, id, new_state}
  end

  def handle_call(:recent_pledges, _from, state), do: {:reply, state, state}

  def handle_call(:total_pledged, _from, state) do
    total =
      state
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()

    {:reply, total, state}
  end

  def handle_cast(:clear, _state), do: {:noreply, []}

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

alias Servy.PledgeServer2

{:ok, _pid} = PledgeServer2.start()

IO.inspect(PledgeServer2.create_pledge("larry", 10))
IO.inspect(PledgeServer2.create_pledge("moe", 20))
IO.inspect(PledgeServer2.create_pledge("curly", 30))
IO.inspect(PledgeServer2.create_pledge("daisy", 40))

PledgeServer2.clear()

IO.inspect(PledgeServer2.create_pledge("grace", 50))

IO.inspect(PledgeServer2.recent_pledges())

IO.inspect(PledgeServer2.total_pledged())
