defmodule Parallel do
  @timeout_ms 3000

  def run do
    # read the urls
    urls = File.read!("./urls")
           |> String.split("\n")
           |> Enum.reject(fn line -> line == "" end)

    # spawn as many processes as the number of urls
    # with the receiver as self
    pids_and_refs = Enum.map(urls, fn url ->
      # spawn a process
      {pid, ref} = spawn_monitor(Fetcher, :fetch, [self, url])
    end)

    # wait for all the processes to finish
    # schedule a terminate message in timeout
    Process.send_after(self, :timeout, @timeout_ms)
    wait(pids_and_refs)
  end

  # used to signal that the process's work is done
  def complete(receiver_pid, data) do
    send(receiver_pid, {:done, self, data})
  end

  defp wait([]), do: :ok
  defp wait(pids_and_refs) do
    # receive messages and reduce the pid and refs
    receive do
      {:done, worker_pid, data} ->
        process(data) # should this also be async?
        # TODO: consolidate the two loops
        # demonitor the ref
        pids_and_refs
        |> Enum.find(fn({pid, ref}) -> pid == worker_pid end)
        |> (fn({_pid, ref}) -> Process.demonitor(ref, [:flush]) end).()

        pids_and_refs
        |> Enum.reject(fn({pid, _ref}) -> pid == worker_pid end)
        |> wait
      :timeout ->
        terminate_stragglers(pids_and_refs)
      {:DOWN, worker_ref, :process, _pid, _reason} ->
        # this process crashed, we are ignoring these guys for now
        pids_and_refs
        |> Enum.reject(fn({_pid, ref}) -> ref == worker_ref end)
        |> wait
    end
  end

  defp terminate_stragglers(pids_and_refs) do
    Enum.each(pids_and_refs, fn({pid, ref}) ->
      Process.demonitor(ref, [:flush])
      Process.exit(pid, :kill)
      IO.puts "killed #{inspect pid} due to timeout"
    end)
  end

  defp process(data) do
    IO.puts "DONE" # " with #{inspect data}"
  end
end
