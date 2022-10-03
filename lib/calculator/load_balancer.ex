defmodule Calculator.LoadBalancer do
  require Logger

  use GenServer

  defstruct [:table, :worker_ids]

  def start_link(worker_ids) do
    Logger.info("Starting Load balancer")

    GenServer.start_link(__MODULE__, worker_ids, name: via_tuple(__MODULE__))
  end

  def choose_worker() do
    Logger.info("Choosing worker")
    GenServer.call(via_tuple(__MODULE__), {:choose_worker})
  end

  def job_started(worker_id) do
    Logger.info("Worker #{inspect(worker_id)} is running")
    GenServer.call(via_tuple(__MODULE__), {:job_started, worker_id})
  end

  @impl GenServer
  def init(worker_ids) do
    Logger.info("Calling init Load balancer")

    table = :ets.new(:workers_registry, [:set, :protected])

    Enum.each(worker_ids, fn worker_id -> :ets.insert(table, {worker_id, :idle}) end)

    {:ok, %__MODULE__{table: table, worker_ids: worker_ids}}
  end

  @impl GenServer
  def handle_call({:choose_worker}, _, %{table: table, worker_ids: worker_ids} = state) do
    idle_worker_id = Enum.find(worker_ids, fn worker_id -> idle?(table, worker_id) end)

    Logger.info("Worker id #{inspect(idle_worker_id)} is idle")

    {:reply, idle_worker_id, state}
  end

  @impl GenServer
  def handle_call({:job_started, started_worker_id}, _, %{table: table} = state) do
    :ets.insert(table, {started_worker_id, :running})

    {:reply, :ok, state}
  end

  defp via_tuple(key) do
    Calculator.Registry.via_tuple({__MODULE__, key})
  end

  defp idle?(table, worker_id) do
    case :ets.lookup(table, worker_id) do
      [{^worker_id, :idle}] -> true
      _ -> false
    end
  end

end
