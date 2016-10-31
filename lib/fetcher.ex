# fetches a url and extracts it's title
defmodule Fetcher do
  use Tesla
  adapter Tesla.Adapter.Hackney

  # TODO extract the parallel worker in a macro?

  # code that runs in a separate worker process
  def fetch(receiver_pid, url) do
    IO.puts "FETCHING #{url} in #{inspect self}"
    {microseconds, response} = :timer.tc fn -> get(url) end
    IO.puts "FETCHED #{url} in #{microseconds / 1000}ms"
    Process.complete(receiver_pid, response)
  end

end
