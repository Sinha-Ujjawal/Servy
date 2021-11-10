defmodule Servy.Tracker do
  @doc """
  Simulates sending a request to an external API
  to get the GPS coordinates of a wildthing.
  """
  def get_location(wildthing) do
    # CODE GOES HERE TO SEND A REQUEST TO THE EXTERNAL API

    # Sleep for 1 second to simulate from the API:
    :timer.sleep(500)

    # Example response returned from the API:
    locations = %{
      "roscoe" => %{lat: "44.4280 N", lng: "110.5885 W"},
      "smokey" => %{lat: "48.4280 N", lng: "113.5885 W"},
      "brutus" => %{lat: "43.4280 N", lng: "110.5885 W"},
      "bigfoot" => %{lat: "29.4280 N", lng: "98.5885 W"}
    }

    Map.get(locations, wildthing)
  end
end
