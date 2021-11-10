defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\r\n")

    headers = parse_headers(header_lines)

    [method, path, _version] = String.split(request_line, " ")

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{method: method, path: path, params: params, headers: headers}
  end

  def parse_headers(header_lines, headers \\ %{}) do
    case header_lines do
      [line | rest] ->
        [key, value] = String.split(line, ": ")
        parse_headers(rest, Map.put(headers, key, value))

      [] ->
        headers
    end
  end

  @doc """
  Parse the given param string of the form `key1=value1&key2=value2`
  into a map with the corresponding keys and values.

  ## Examples
      iex> param_string = "name=Baloo&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", param_string)
      %{"name" => "Baloo", "type" => "Brown"}
      iex> Servy.Parser.parse_params("multipart/form-data", param_string)
      %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params(_content_type, _params_string), do: %{}
end
