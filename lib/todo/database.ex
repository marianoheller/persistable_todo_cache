defmodule Todo.Database do
  use GenServer
  @qty_workers 3

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    worker_index = get_worker(key)
    GenServer.cast(:database_server, {:store, worker_index, key, data})
  end

  def get(key) do
    worker_index = get_worker(key)
    GenServer.call(:database_server, {:get, worker_index, key})
  end

  def init(db_folder) do
    new_workers =
      Map.new(0..(@qty_workers - 1), fn i -> {i, Todo.DatabaseWorker.start(db_folder)} end)

    {:ok, {db_folder, new_workers}}
  end

  def handle_cast({:store, worker_index, key, data}, {db_folder, workers}) do
    {:ok, worker} = Map.get(workers, worker_index)
    Todo.DatabaseWorker.store(worker, key, data)
    {:noreply, {db_folder, workers}}
  end

  def handle_call({:get, worker_index, key}, caller, {db_folder, workers}) do
    {:ok, worker} = Map.get(workers, worker_index)

    spawn(fn ->
      data = Todo.DatabaseWorker.get(worker, key)
      GenServer.reply(caller, data)
    end)

    {:noreply, db_folder}
  end

  defp get_worker(key) do
    :erlang.phash2(key, @qty_workers)
  end
end
