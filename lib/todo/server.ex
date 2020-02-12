defmodule Todo.Server do
  use GenServer

  def start(name) do
    GenServer.start(Todo.Server, name)
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def entries(pid, key) do
    GenServer.call(pid, {:entries, key})
  end

  def init(name) do
    send(self(), {:real_init, name})
    {:ok, nil}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_call({:entries, key}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, key), {name, todo_list}}
  end

  def handle_info({:real_init, name}, _) do
    {:noreply, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  def handle_info(_, state) do
    state
  end
end
