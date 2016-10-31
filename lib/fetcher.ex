# fetches a url and extracts it's title
defmodule Fetcher do
  use Tesla
  adapter Tesla.Adapter.Hackney

  # TODO extract the parallel worker in a macro?

  def fetch(receiver_pid, url) do
    get url
  end

end
