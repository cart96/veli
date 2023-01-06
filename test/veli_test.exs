defmodule VeliTest do
  use ExUnit.Case
  doctest Veli

  @form %{"username" => "kitty", "password" => "hellokitty", "age" => 17, "accepted" => true}
  @rules %{
    "username" => %{type: :string, min: 3, max: 32, match: ~r/^[a-zA-Z0-9_]*$/},
    "password" => %{type: :string, min: 8, max: 72},
    "age" => %{type: :integer, min: 13},
    "accepted" => %{type: :bool, match: true}
  }

  test "validate simple string" do
    assert Veli.validate("hello", %{type: :string, match: ~r/^(h|H)/}) === :ok
  end

  test "validate simple form" do
    assert Veli.validate_form(@form, @rules) |> Veli.get_error() === nil
  end

  test "fail age validation" do
    form = %{@form | "age" => 11}
    assert Veli.validate_form(form, @rules) |> Veli.get_error() === {"age", :min_error}
  end
end
