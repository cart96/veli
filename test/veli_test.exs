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

  test "simple string" do
    assert Veli.valid("hello", type: :string, match: ~r/^(h|H)/) == nil
  end

  test "simple form" do
    form = %{username: "bob", age: 15}
    assert Veli.valid(form, @rules) |> Veli.error() == nil
  end

  test "pass another type instead of map" do
    assert Veli.valid(5, @rules) |> Veli.error() != nil
  end

  test "fail age validation" do
    form = %{username: "bob", age: 11}
    assert Veli.valid(form, @rules) |> Veli.error() == {:min, "Age must be at least 13."}
  end

  test "palindrome string" do
    rule = [type: :string, run: fn value -> String.reverse(value) == value end]

    assert Veli.valid("wow", rule) |> Veli.error() == nil
    assert Veli.valid("racecar", rule) |> Veli.error() == nil
    assert Veli.valid("height", rule) |> Veli.error() != nil
  end

  test "nullable value" do
    rule = [nullable: true, type: :string]

    assert Veli.valid("hello", rule) |> Veli.error() == nil
    assert Veli.valid(nil, rule) |> Veli.error() == nil
    assert Veli.valid(5, rule) |> Veli.error() != nil
  end

  test "map strict matching" do
    form_1 = %{username: "bob", age: 15}
    form_2 = %{age: 15, username: "bob"}
    form_3 = %{age: 15, username: "bob", another: 3}
    form_4 = %{username: "bob", another: 3}

    assert Veli.valid(form_1, @rules) |> Veli.error() == nil
    assert Veli.valid(form_2, @rules) |> Veli.error() == nil
    assert Veli.valid(form_3, @rules) |> Veli.error() != nil
    assert Veli.valid(form_4, @rules) |> Veli.error() != nil
  end

  test "simple list" do
    list = [5, 3, 2, 1]
    rule = %Veli.Types.List{rule: [nullable: false, type: :integer]}

    assert Veli.valid(list, rule) |> Veli.error() == nil
  end

  test "format validators" do
    assert Veli.valid("icecat696@proton.me", format: :email) == nil
    assert Veli.valid("https://cart96.github.io/", format: :url) == nil
    assert Veli.valid("a-slug", format: :slug) == nil
    # a random ip adress, of course.
    assert Veli.valid("255.75.35.23", format: :ipv4) == nil
    assert Veli.valid("FE80:0000:0000:0000:0202:B3FF:FE1E:8329", format: :ipv6) == nil
    assert Veli.valid("hello", format: :ascii) == nil
    assert Veli.valid("can print", format: :printable) == nil
    assert Veli.valid("42a6826c-dc20-4d4d-8ffd-20ca5eac4967", format: :uuid) == nil
    assert Veli.valid("89:FF:70:A8:90:2A", format: :mac) == nil
    assert Veli.valid("valid_user-name", format: :username) == nil
    # random generated credit card number
    assert Veli.valid("4058523347223731", format: :cc) == nil
    # random generated phone number
    assert Veli.valid("+968433266928", format: :e164) == nil
    # also random
    assert Veli.valid("1MNTGrgCuVwpuv84dMxLZJ3rurwsHzh7h8", format: :btcaddr) == nil
    assert Veli.valid("6.1.0-beta", format: :semver) == nil
  end
end
