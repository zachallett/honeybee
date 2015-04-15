defmodule HoneyBee.RouterTest do
  use ExUnit.Case, async: true

  @tag :distributed
  test "route requests accross nodes" do
    assert HoneyBee.Router.route("hello", Kernel, :node, []) ==
           :"foo@Zacs-MacBook-Pro"
    assert HoneyBee.Router.route("world", Kernel, :node, []) ==
           :"bar@Zacs-MacBook-Pro"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      HoneyBee.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
