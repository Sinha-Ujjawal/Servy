defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    headers = parse_headers(header_lines)

    [method, path, _version] = String.split(request_line, " ")

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{method: method, path: path, params: params, headers: headers}
  end

  defp parse_headers(header_lines, headers \\ %{}) do
    case header_lines do
      [line | rest] ->
        [key, value] = String.split(line, ": ")
        parse_headers(rest, Map.put(headers, key, value))

      [] ->
        headers
    end
  end

  defp parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  defp parse_params(_content_type, _params_string), do: %{}
end
