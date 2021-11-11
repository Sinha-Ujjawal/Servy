defmodule Servy.SensorServer do
  @name :sensor_server
  @refresh_interval :timer.minutes(10)

  use GenServer
  alias Servy.VideoCam
  alias Servy.Tracker

  # Client Interface
  def start do
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  # Server Callbacks
  defp schedule_refresh do
    IO.puts("Scheduling the refresh to run after: #{inspect(@refresh_interval)} ms")
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  def init(_state) do
    initial_state = run_tasks_to_get_sensor_data()
    schedule_refresh()
    {:ok, initial_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh, _state) do
    IO.puts("Refreshing the cache...")
    new_state = run_tasks_to_get_sensor_data()
    schedule_refresh()
    {:noreply, new_state}
  end

  def run_tasks_to_get_sensor_data do
    IO.puts("Running tasks to get sensor data...")

    task = Task.async(fn -> Tracker.get_location("bigfoot") end)

    snapshots =
      [
        "cam-1-snapshot-#{:rand.uniform(1000)}",
        "cam-2-snapshot-#{:rand.uniform(1000)}",
        "cam-3-snapshot-#{:rand.uniform(1000)}"
      ]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Task.await_many(:infinity)

    bigfoot_location = Task.await(task, :infinity)

    %{snapshots: snapshots, location: bigfoot_location}
  end
end
