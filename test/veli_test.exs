defmodule VeliTest do
  use ExUnit.Case

  @rules %Veli.Types.Map{
    rule: %{
      username: [
        # Validation
        type: {:string, false},
        min: 3,
        max: 32,
        match: ~r/^[a-zA-Z0-9_]*$/,
        # Errors
        _type: "Username must be a string.",
        _min: "Username is too short.",
        _max: "Username is too long.",
        _match: "Username must only contains alphanumeric characters."
      ],
      age: [
        # Validation
        type: {:integer, false},
        min: 13,
        # Errors
        _type: "Age must be an integer.",
        _min: "Age must be at least 13."
      ]
    },
    error: "Form must be an object."
  }

  test "validate simple string" do
    assert Veli.valid("hello", type: {:string, false}, match: ~r/^(h|H)/) |> Veli.error() === nil
  end

  test "validate simple form" do
    form = %{username: "bob", age: 15}
    assert Veli.valid(form, @rules) |> Veli.error() === nil
  end

  test "pass another type instead of map" do
    assert Veli.valid(5, @rules) |> Veli.error() !== nil
  end

  test "fail age validation" do
    form = %{username: "bob", age: 11}
    assert Veli.valid(form, @rules) |> Veli.error() === {:min, "Age must be at least 13."}
  end

  test "validate if a string is palindrome" do
    rule = [type: {:string, false}, run: fn value -> String.reverse(value) === value end]

    assert Veli.valid("wow", rule) |> Veli.error() === nil
    assert Veli.valid("racecar", rule) |> Veli.error() === nil
    assert Veli.valid("height", rule) |> Veli.error() !== nil
  end
end
