defmodule Servy.Plugins do
  @moduledoc """
  Servy Plugins
  """

  alias Servy.Conv

  @doc "log 404 requests"
  def track(conv = %Conv{status: 404, path: path}) do
    if Mix.env() != :test do
      IO.puts("Warning: #{path} is on the loose!")
    end

    conv
  end

  def track(conv = %Conv{}), do: conv

  def rewrite_path(conv = %Conv{path: "/wildlife"}) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv = %Conv{}), do: conv

  def log(conv = %Conv{}) do
    if Mix.env() == :dev do
      IO.inspect(conv)
    end

    conv
  end
end
