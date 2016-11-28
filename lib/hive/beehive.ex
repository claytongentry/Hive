defmodule Hive.Beehive do
  use Supervisor
  alias Hive.Bee
  require Logger

  @poolboy :hive_poolboy

  def start_link(opts \\ []) do
    Logger.info "Starting up the hive supervisor..."
    Supervisor.start_link __MODULE__, [], opts
  end

  def init([]) do
    hive_opts = [
      name: {:local, @poolboy},
      worker_module: Bee,
      size: 20,
      max_overflow: 10,
      strategy: :fifo
    ]

    Logger.info "Bees assemble!"
    children = [
      :poolboy.child_spec(@poolboy, hive_opts) # spins up our hive of bees
    ]

    supervise(children, strategy: :one_for_one, name: __MODULE__) # supervise the pool
  end


  # Send multiple bees to gather honey in parallel
  # n is the number of "honey" deliveries you want to receive
  def all_gather_honey(n, i \\ 0)
  def all_gather_honey(n, i) when n == i, do: {:ok, :all_spawned}
  def all_gather_honey(n, i) do
    spawn &gather_honey/0

    all_gather_honey n, i + 1
  end

  # Check out a bee from the pool and send him to get honey
  def gather_honey do
    # Poolboy will pass a worker from the pool into the function
    # See Line 76 in poolboy/src/poolboy.erl
    :poolboy.transaction @poolboy, &Bee.gather_honey/1

    # Could also write...
    # :poolboy.transaction @poolboy, fn(pid) -> Bee.gather_honey(pid) end
  end
end
