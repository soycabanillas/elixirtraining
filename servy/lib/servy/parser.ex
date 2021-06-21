defmodule Servy.Parser do
  alias Servy.Conv
  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = top |> String.split("\n")

    [method, path, _] = request_line |> String.split(" ")

    headers = parse_headers(header_lines, %{})

    params = parse_params(headers["Content-Type"], params_string)

    IO.inspect header_lines

    %Conv{
        method: method,
        path: path,
        params: params,
        headers: headers
     }
  end

  def parse_headers([head | tail], headers) do
    [key, value] = head |> String.split(": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers

  @doc """
  Parses the given param string of the form `key1=value1&key2=value@`
  into a map with corresponding keys and values

  ## Examples
    iex> params_string = "name=Baloo&type=Brown"
    iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
    %{ "name" => "Baloo", "type" => "Brown"}
    iex> Servy.Parser.parse_params("multipart/form-data", params_string)
    %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}

end
