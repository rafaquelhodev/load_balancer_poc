defmodule SupervisorTest do
  use ExUnit.Case

  test "restarts worker" do
    [{old_worker_pid, _}] = Registry.lookup(Calculator.Registry, {Calculator.CalculatorWorker, 2})

    Process.exit(old_worker_pid, :kill)

    Process.sleep(500)

    [{new_worker_pid, _}] = Registry.lookup(Calculator.Registry, {Calculator.CalculatorWorker, 2})

    assert old_worker_pid != new_worker_pid
  end
end
