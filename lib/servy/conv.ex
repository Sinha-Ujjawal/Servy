defmodule Servy.Conv do
  defstruct method: "",
            path: "",
            resp_content_type: "text/html",
            resp_body: "",
            status: nil,
            params: %{},
            headers: %{}

  def full_status(_conv = %Servy.Conv{status: status}) do
    "#{status} #{status_reason(status)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "CREATED",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Interal Server Error"
    }[code]
  end
end
