defmodule Veli do
  @moduledoc """
  Veli is a simple validation library for elixir.

  ## Rules
  ### Simple Rules
  When you validate simple types (like a string or an integer),
  you must use simple rules. Which is a keyword list.

      rule = [type: :string, run: fn value -> String.reverse(value) === value end]
      Veli.valid("wow", rule) |> Veli.error() === nil

  ### List Rules
  When you need to validate every item on a list,
  you must use `Veli.Types.List` struct so validator can know if it is validating a string or a value.

      rule = %Veli.Types.List{rule: [type: :integer]}
      Veli.valid([4, 2, 7, 1], rule) |> Veli.error() === nil

  ### Map Rules
  When you need to validate a map (an object),
  you must use `Veli.Types.Map` struct so validator can know if it is validating a map or a value.

      rule = %Veli.Types.Map{rule: %{
        username: [type: :string],
        age: [type: :string, min: 13]
      }}
      Veli.valid(%{username: "bob", age: 16}, rule) |> Veli.error() === nil

  ## Custom Errors
  By default, Any error returns `false`. You can specify custom errors with adding underscore (_) prefix.

      rule = [type: :integer, _type: "Value must be an integer!"]
      Veli.valid(10, rule) |> Veli.error() # nil
      Veli.valid("invalid value", rule) |> Veli.error() # "Value must be an integer!"

  ### Custom Errors for Map or List
  As you can see in `Veli.Types.Map` or `Veli.Types.List`, they both have a field named "error" which is nil by default.
  You can specify custom errors with "error" field.

      rule = %Veli.Types.Map{
        rule: %{
          username: [type: :string],
          age: [type: :string, min: 13]
        },
        error: "Not a valid object."
      }
      Veli.valid(%{username: "bob", age: 16}, rule) |> Veli.error() # nil
      Veli.valid(96, rule) |> Veli.error() # "Not a valid object."

  ### More Example
  You can read library tests for more example.
  """

  @doc """
  Validate a value with rules.
  Returns a keyword list which contains results. You should not process that result yourself. Use `Veli.errors` or `Veli.error` for processing results instead.

  ## Example

      rule = [type: :string, match: ~r/^https?/]
      Veli.valid("wow", rule) |> Veli.error() !== nil
      Veli.valid("https://hex.pm", rule) |> Veli.error() === nil

  More examples can be found in library tests.
  """
  @spec valid(any, keyword | Veli.Types.List | Veli.Types.Map) :: keyword
  def valid(values, rules) when is_struct(rules, Veli.Types.List) do
    %{rule: rules} = rules

    if is_list(values) do
      values
      |> Enum.with_index()
      |> Enum.map(fn {value, index} -> {index, valid(value, rules)} end)
    else
      [type: rules[:error] || false]
    end
  end

  def valid(values, rules_map) when is_struct(rules_map, Veli.Types.Map) do
    %{rule: rules_map} = rules_map

    if is_map(values) or is_struct(values) do
      values
      |> Map.keys()
      |> Enum.filter(fn key -> rules_map[key] !== nil end)
      |> Enum.map(fn key ->
        value = values[key]
        rules = rules_map[key]

        {key, valid(value, rules)}
      end)
    else
      [type: rules_map[:error] || false]
    end
  end

  def valid(value, rules) when is_list(rules) do
    {:ok, modules} = :application.get_key(:veli, :modules)

    modules
    |> Enum.filter(fn module -> Enum.fetch(module_to_path(module), 2) === {:ok, "Validators"} end)
    |> Enum.filter(fn module ->
      rule_atom = validator_to_atom(module)
      Enum.any?(rules, fn {atom, _value} -> rule_atom === atom end)
    end)
    |> Enum.map(fn module ->
      rule_atom = validator_to_atom(module)
      rule = rules[rule_atom]

      case module.valid?(value, rule) do
        true ->
          {rule_atom, true}

        false ->
          fail_msg = rules[String.to_atom("_" <> Atom.to_string(rule_atom))]
          {rule_atom, fail_msg || false}
      end
    end)
  end

  def valid(_value, _rules) do
    raise ArgumentError, message: "Unexpected type for rules."
  end

  @doc """
  Returns all false validates.

  ## Example

      rule = %Veli.Types.List{rules: [type: :float]}
      Veli.valid([5, 3.2, "how"], rule) |> Veli.errors()
  """
  @spec errors(keyword) :: keyword
  def errors(result) do
    result
    |> Enum.map(fn {atom, value} -> if is_list(value), do: errors(value), else: {atom, value} end)
    |> List.flatten()
    |> Enum.filter(fn {_atom, value} -> value !== true end)
  end

  @doc """
  Returns first error from validate result.
  Returns `nil` if everything is valid.

  ## Example

      rule = %Veli.Types.List{rules: [type: :float]}
      Veli.valid([5, 3.2, "how"], rule) |> Veli.error()
  """
  @spec error(keyword) :: tuple
  def error(result) do
    result
    |> errors
    |> List.first()
  end

  defp module_to_path(module) do
    String.split(to_string(module), ".")
  end

  defp validator_to_atom(module) do
    module
    |> module_to_path
    |> Enum.fetch!(3)
    |> String.downcase(:ascii)
    |> String.to_atom()
  end
end
