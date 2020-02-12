defmodule Todo.List do
  defstruct auto_id: 1, entries: Map.new()
  alias Todo.List, as: List


  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %List{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(%List{entries: entries, auto_id: auto_id} = todo_list, entry) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)
    %List{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def entries(%List{entries: entries}, date) do
    entries
    |> Stream.filter(fn {_, entry} ->
      entry.date == date
    end)
    |> Enum.map(fn {_, entry} ->
      entry
    end)
  end

  def delete_entry(%List{entries: entries} = todo_list, target_id) do
    case entries[target_id] do
      nil ->
        todo_list

      _ ->
        new_entries =
          entries
          |> Stream.filter(fn {_, entry} ->
            entry.id == target_id
          end)

        %List{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(%List{entries: entries} = todo_list, target_id, updater) do
    new_entries =
      entries
      |> Enum.map(fn {id, entry} ->
        case id do
          ^target_id -> safeUpdater(entry, updater)
          _ -> entry
        end
      end)

    %List{todo_list | entries: new_entries}
  end

  defp safeUpdater(entry, updater) do
    old_entry_id = entry.id
    new_entry = %{id: ^old_entry_id} = updater.(entry)
    new_entry
  end
end
