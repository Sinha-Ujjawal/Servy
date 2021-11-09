defmodule Servy.Plugins do
  @moduledoc """
  Servy Plugins
  """

  @doc "log 404 requests"
  def track(conv = %{status: 404, path: path}) do
    IO.puts("Warning: #{path} is on the loose!")
    conv
  end

  def track(conv), do: conv

  def log(data), do: IO.inspect(data)

  def rewrite_path(conv = %{path: "/wildlife"}) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv
end
