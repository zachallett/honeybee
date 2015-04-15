defmodule HoneyBee.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @manager_name HoneyBee.EventManager
  @registry_name HoneyBee.Registry
  @ets_registry_name HoneyBee.Registry
  @bucket_sup_name HoneyBee.Bucket.Supervisor

  def init(:ok) do
    ets = :ets.new(@ets_registry_name,
                    [:set, :public, :named_table, {:read_concurrency, true}])
    children = [
      worker(GenEvent, [[name: @manager_name]]),
      supervisor(HoneyBee.Bucket.Supervisor, [[name: @bucket_sup_name]]),
      supervisor(Task.Supervisor, [[name: HoneyBee.RouterTasks]]),
      worker(HoneyBee.Registry, [ets, @manager_name, @bucket_sup_name, [name: @registry_name]])
    ]

    supervise(children, strategy: :one_for_one)
  end

end
