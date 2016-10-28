defmodule Crawler do
end


# read the urls
urls = File.read!("./urls") |> String.split("\n")
IO.inspect(urls |> hd)

# spawn as many processes as number of urls
# with the receiver as self
Enum.map(urls, fn url ->
  # spawn a process
  spawn()
end)
