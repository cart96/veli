defmodule VeliTest do
  use ExUnit.Case
  doctest Veli

  test "greets the world" do
    assert Veli.hello() == :world
  end
end
