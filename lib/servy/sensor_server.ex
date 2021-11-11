defmodule Servy.SensorServer do
  @name :sensor_server

  use GenServer
  alias Servy.VideoCam
  alias Servy.Tracker

  defmodule State do
    # mins
    @refresh_interval 10
    defstruct refresh_interval: @refresh_interval, sensor_data: %{}
  end

  # Client Interface
  def start_link(%{refresh_interval: refresh_interval}) do
    IO.puts("Starting the sensor server with refresh_interval: #{refresh_interval} mins ...")
    GenServer.start_link(__MODULE__, %State{refresh_interval: refresh_interval}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  # Server Callbacks
  defp schedule_refresh(refresh_interval) do
    IO.puts("Scheduling the refresh to run after: #{inspect(refresh_interval)} mins")
    Process.send_after(self(), :refresh, :timer.minutes(refresh_interval))
  end

  def init(state = %State{refresh_interval: refresh_interval}) do
    sensor_data = run_tasks_to_get_sensor_data()
    schedule_refresh(refresh_interval)
    {:ok, %{state | sensor_data: sensor_data}}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  def handle_info(:refresh, state = %State{refresh_interval: refresh_interval}) do
    IO.puts("Refreshing the cache...")
    sensor_data_updated = run_tasks_to_get_sensor_data()
    schedule_refresh(refresh_interval)
    {:noreply, %{state | sensor_data: sensor_data_updated}}
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
