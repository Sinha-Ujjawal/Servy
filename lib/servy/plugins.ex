defmodule Servy.Plugins do
  @moduledoc """
  Servy Plugins
  """

  alias Servy.Conv

  @doc "log 404 requests"
  def track(conv = %Conv{status: 404, path: path}) do
    IO.puts("Warning: #{path} is on the loose!")
    conv
  end

  def track(conv = %Conv{}), do: conv

  def rewrite_path(conv = %Conv{path: "/wildlife"}) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv = %Conv{}), do: conv

  def log(conv = %Conv{}), do: IO.inspect(conv)
end
