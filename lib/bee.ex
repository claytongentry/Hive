defmodule Hive.Bee do
  require Logger
  use GenServer

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link __MODULE__, [], opts
    Logger.info "Bee #{inspect pid} standing by..."

    {:ok, pid}
  end

  def init([]) do
    {:ok, %{honey: nil}} # :(
  end

  # PID passed in by the Beehive call
  def gather_honey(pid), do: GenServer.call(pid, {pid, :gather_honey})

  def handle_call({pid, :gather_honey}, from, state) do
    Logger.info "Bee #{inspect pid} going to get some honey!"
    reply = %{ delivery: "honey!" }
    Logger.info "Bee #{inspect pid} got some honey!"

    {:reply, reply, state}
  end
end
