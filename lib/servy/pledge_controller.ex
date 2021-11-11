defmodule Servy.PledgeController do
  alias Servy.PledgeServer

  def create(conv, _params = %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    PledgeServer.create_pledge(name, String.to_integer(amount))
    %{conv | status: 201, resp_body: "#{name} pledged #{amount}!"}
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer.recent_pledges()
    %{conv | status: 200, resp_body: inspect(pledges)}
  end

  def total_pledged(conv) do
    total = PledgeServer.total_pledged()
    %{conv | status: 200, resp_body: inspect(total)}
  end
end
