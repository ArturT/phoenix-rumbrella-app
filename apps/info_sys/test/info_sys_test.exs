defmodule InfoSysTest do
  use ExUnit.Case
  alias InfoSys.Result
  doctest InfoSys

  defmodule TestBackend do
    def start_link(query, ref, owner, limit) do
      Task.start_link(__MODULE__, :fetch, [query, ref, owner, limit])
    end

    def fetch("result", ref, owner, _limit) do
      send(owner, {:results, ref, [%Result{backend: "test", text: "result"}]})
    end

    def fetch("none", ref, owner, _limit) do
      send(owner, {:results, ref, []})
    end

    def fetch("timeout", _ref, owner, _limit) do
      send(owner, {:backend, self()})
      :timer.sleep(:infinity)
    end
  end

  test "compute/2 with backend results" do
    assert [%Result{backend: "test", text: "result"}] = InfoSys.compute("result", backends: [TestBackend])
  end

  test "compute/2 with no backend results" do
    assert [] = InfoSys.compute("none", backends: [TestBackend])
  end

  test "compute/2 with timeout returns no results and kills workers" do
    # short timeout 10ms
    results = InfoSys.compute("timeout", backends: [TestBackend], timeout: 10)

    # ensure we get zero results back after timeout period
    assert results == []

    # make sure backend receives the data we expect
    assert_receive {:backend, backend_pid}

    # With that backend_pid, we monitor the backend process and verify that we receive
    # a :DOWN message ensuring that our code successfully killed the backend after timing out.
    ref = Process.monitor(backend_pid)

    # assert_receive by default waits for 100ms before failing the test.
    # You can explicitly pass a timeout as an optional second argument for cases you are willing to wait a longer period.
    assert_receive {:DOWN, ^ref, :process, _pid, _reason}

    # make sure there are no further :DOWN or :timedout messages in our inbox by calling refute_received.
    refute_received {:DOWN, _, _, _, _}
    refute_received :timedout

    # Notice we used refute_received instead of refute_receive. These functions are different.
    # Use refute_receive to wait 100 milliseconds and make sure no matching message arrives at the inbox.
    # Because we don’t expect messages to arrive in the first place, calling refute_receive multiple times may quickly become expensive as each call waits 100ms.
    # Since we’ve already made sure the backend is down, there is no need to wait as the messages we are refuting would already be in our inbox if they leaked.
    # We can use refute_received for this purpose. Saving a few milliseconds might not seem like much, but across hundreds of tests, they add up.
  end
end
