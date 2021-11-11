defmodule Servy.PledgeController do
  alias Servy.PledgeServer2

  def create(conv, _params = %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    PledgeServer2.create_pledge(name, String.to_integer(amount))
    %{conv | status: 201, resp_body: "#{name} pledged #{amount}!"}
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer2.recent_pledges()
    %{conv | status: 200, resp_body: inspect(pledges)}
  end

  def total_pledged(conv) do
    total = PledgeServer2.total_pledged()
    %{conv | status: 200, resp_body: inspect(total)}
  end
end
