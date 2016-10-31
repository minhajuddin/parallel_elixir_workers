defmodule Parallel do
  @timeout 5000

  def run do

    # read the urls
    urls = File.read!("./urls") |> String.split("\n")
    IO.inspect(urls |> hd)

    # spawn as many processes as the number of urls
    # with the receiver as self
    pids_and_refs = Enum.map(urls, fn url ->
      # spawn a process
      {pid, ref} = spawn_monitor(Fetcher, :fetch, [self, url])
    end)

    # wait for all the processes to finish
    wait(pids_and_refs, @timeout)
  end

  defp wait(pids_and_refs, timeout) do
    # schedule a terminate message in timeout
    Process.send_after(self, :timeout, timeout)

    # receive messages and reduce the pid and refs
    receive do
      {:done, data} ->
        :ok
      :terminate ->
        terminate_stragglers(pids_and_refs)
    end
  end

  defp terminate_stragglers(pids_and_refs) do
  end
end
