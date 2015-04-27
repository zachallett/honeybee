defmodule HoneyBeeServer.Command do
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> HoneyBeeServer.Command.parse "CREATE shopping\r\n"
      {:ok, {:create, "shopping"}}

      iex> HoneyBeeServer.Command.parse "CREATE  shopping  \r\n"
      {:ok, {:create, "shopping"}}

      iex> HoneyBeeServer.Command.parse "SET shopping milk 1\r\n"
      {:ok, {:set, "shopping", "milk", "1"}}

      iex> HoneyBeeServer.Command.parse "GET shopping milk\r\n"
      {:ok, {:get, "shopping", "milk"}}

      iex> HoneyBeeServer.Command.parse "DELETE shopping eggs\r\n"
      {:ok, {:delete, "shopping", "eggs"}}

  Unknown commands or commands with the wrong number of
  arguments return an error:

      iex> HoneyBeeServer.Command.parse "UNKNOWN shopping eggs\r\n"
      {:error, :unknown_command}

      iex> HoneyBeeServer.Command.parse "GET shopping\r\n"
      {:error, :unknown_command}

  """

  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket]          -> {:ok, {:create, bucket}}
      ["LIST", bucket]            -> {:ok, {:list, bucket}}
      ["GET", bucket, key]        -> {:ok, {:get, bucket, key}}
      ["SET", bucket, key, value] -> {:ok, {:set, bucket, key, value}}
      ["DELETE", bucket, key]     -> {:ok, {:delete, bucket, key}}
      _                           -> {:error, :unknown_command}
    end
  end

  @doc """
    Runs the given command
  """
  def run(command)

  def run({:create, bucket}) do
    HoneyBee.Registry.create(HoneyBee.Registry, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:list, bucket}) do
    lookup bucket, fn pid ->
      value = HoneyBee.Bucket.list(pid)
      {:ok, "#{value}\r\nOK\r\n"}
    end
  end

  def run({:get, bucket, key}) do
    lookup bucket, fn pid ->
      value = HoneyBee.Bucket.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end
  end

  def run({:set, bucket, key, value}) do
    lookup bucket, fn pid ->
      HoneyBee.Bucket.set(pid, key, value)
      {:ok, "OK\r\n"}
    end
  end

  def run({:delete, bucket, key}) do
    lookup bucket, fn pid ->
      HoneyBee.Bucket.delete(pid, key)
      {:ok, "OK\r\n"}
    end
  end

  defp lookup(bucket, callback) do
    case HoneyBee.Registry.lookup(HoneyBee.Registry, bucket) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
