defmodule Calculator.CalculatorSupervisor do

  def sum(num1, num2) do
    Calculator.LoadBalancer.choose_worker()
    |> Calculator.CalculatorWorker.sum(num1, num2)
  end

  def start_link() do
    worker_ids = 1..3

    workers = Enum.map(worker_ids, &worker_specification(&1))

    load_balancer = load_balancer_specification(worker_ids)

    Supervisor.start_link(workers ++ [load_balancer], strategy: :one_for_one)
  end

  def worker_specification(worker_id) do
    default_spec = {Calculator.CalculatorWorker, {worker_id}}
    Supervisor.child_spec(default_spec, id: worker_id)
  end

  def load_balancer_specification(worker_ids) do
    Supervisor.child_spec({Calculator.LoadBalancer, worker_ids}, id: Calculator.LoadBalancer)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
end
