defmodule Calculator.CalculatorWorker do
  require Logger

  use GenServer

  def start_link({worker_id}) do
    Logger.info("Starting calculator worker #{worker_id}")

    GenServer.start_link(__MODULE__, nil, name: via_tuple(worker_id))
  end

  def idle?(worker_id) do
    GenServer.call(via_tuple(worker_id), {:idle})
  end

  def sum(worker_id, num1, num2) do
    Logger.info("[Sum] Worker #{worker_id}")

    Calculator.LoadBalancer.job_started(worker_id)

    GenServer.call(via_tuple(worker_id), {:sum, num1, num2})

    # Calculator.LoadBalancer.finished(worker_id)

  end

  @impl GenServer
  def init(_) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:sum, num1, num2}, _, state) do

    {:reply, num1+num2, state}
  end

  @impl GenServer
  def handle_call({:sum, num1, num2}, _, state) do

    {:reply, num1+num2, state}
  end

  defp via_tuple(key) do
    Calculator.Registry.via_tuple({__MODULE__, key})
  end
end
