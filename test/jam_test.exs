defmodule JamTest do
  use ExUnit.Case
  doctest Jam

  test "greets the world" do
    assert Jam.hello() == :world
  end
end
