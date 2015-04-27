defmodule HoneyBee.Bucket do

  use Timex

  def start_link do
    Agent.start_link(fn -> HashDict.new end)
  end

  def list(bucket) do
    Agent.get(bucket, fn(dict) ->
      HashDict.to_list(dict) |> Enum.map(&Tuple.to_list(&1)) |> Enum.map_join("\n", fn (x) -> "#{hd(x)} => #{hd(tl(x))[:value]}\ttime => #{hd(tl(x))[:time]}" end)
    end)
  end

  def get(bucket, key) do
    Agent.get(bucket, &HashDict.get(&1, key)[:value])
  end

  def set(bucket, key, value) do
    time = DateFormat.format!(Date.local, "{ISO}")
    Agent.update(bucket, &HashDict.put(&1, key, [value: value, time: time]))
  end

  def delete(bucket, key) do
    Agent.get_and_update(bucket, fn dict->
      HashDict.pop(dict, key)
    end)
  end

end
