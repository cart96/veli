defmodule VeliTest do
  use ExUnit.Case

  @rules %Veli.Types.Map{
    rule: %{
      username: [
        # Validation
        type: :string,
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
        type: :integer,
        min: 13,
        # Errors
        _type: "Age must be an integer.",
        _min: "Age must be at least 13."
      ]
    },
    strict: true,
    error: "Form must be an object."
  }

  test "validate simple string" do
    assert Veli.valid("hello", type: :string, match: ~r/^(h|H)/) |> Veli.error() === nil
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
    rule = [type: :string, run: fn value -> String.reverse(value) === value end]

    assert Veli.valid("wow", rule) |> Veli.error() === nil
    assert Veli.valid("racecar", rule) |> Veli.error() === nil
    assert Veli.valid("height", rule) |> Veli.error() !== nil
  end

  test "nullable value" do
    rule = [nullable: true, type: :string]

    assert Veli.valid("hello", rule) |> Veli.error() === nil
    assert Veli.valid(nil, rule) |> Veli.error() === nil
    assert Veli.valid(5, rule) |> Veli.error() !== nil
  end

  test "map strict matching" do
    form_1 = %{username: "bob", age: 15}
    form_2 = %{age: 15, username: "bob"}
    form_3 = %{age: 15, username: "bob", another: 3}
    form_4 = %{username: "bob", another: 3}

    assert Veli.valid(form_1, @rules) |> Veli.error() === nil
    assert Veli.valid(form_2, @rules) |> Veli.error() === nil
    assert Veli.valid(form_3, @rules) |> Veli.error() !== nil
    assert Veli.valid(form_4, @rules) |> Veli.error() !== nil
  end

  test "validate simple list" do
    list = [5, 3, 2, 1]
    rule = %Veli.Types.List{rule: [nullable: false, type: :integer]}

    assert Veli.valid(list, rule) |> Veli.error() === nil
  end
end
