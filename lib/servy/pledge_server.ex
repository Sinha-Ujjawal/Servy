defmodule Servy.PledgeServer do
  alias Servy.GenericServer

  @name :pledge_server

  # Client Interface
  def start do
    IO.puts("Starting the pledge server...")
    GenericServer.start(__MODULE__, [], @name)
  end

  def create_pledge(name, amount), do: GenericServer.call(@name, {:create_pledge, name, amount})

  def recent_pledges(), do: GenericServer.call(@name, :recent_pledges)

  def total_pledged(), do: GenericServer.call(@name, :total_pledged)

  def clear(), do: GenericServer.cast(@name, :clear)

  # Server Callbacks
  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}
  end

  def handle_call(:recent_pledges, state), do: {state, state}

  def handle_call(:total_pledged, state) do
    total =
      state
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()

    {total, state}
  end

  def handle_cast(:clear, _state), do: []

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# alias Servy.PledgeServer

# _pid = PledgeServer.start()

# IO.inspect(PledgeServer.create_pledge("larry", 10))
# IO.inspect(PledgeServer.create_pledge("moe", 20))
# IO.inspect(PledgeServer.create_pledge("curly", 30))
# IO.inspect(PledgeServer.create_pledge("daisy", 40))

# PledgeServer.clear()

# IO.inspect(PledgeServer.create_pledge("grace", 50))

# IO.inspect(PledgeServer.recent_pledges())

# IO.inspect(PledgeServer.total_pledged())
