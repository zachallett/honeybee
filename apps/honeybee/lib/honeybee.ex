defmodule HoneyBee do
  use Application

  def start(_type, _args) do
    HoneyBee.Supervisor.start_link
  end

end
