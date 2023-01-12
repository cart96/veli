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
        age: [type: :integer, min: 13]
      }}
      Veli.valid(%{username: "bob", age: 16}, rule) |> Veli.error() === nil

  ## Ordering
  You must order your rules correctly to make them work properly. For example, if you put "nullable" rule after "type" rule, you will get type error.

      rule = [nullable: true, type: :integer]
      Veli.valid(5, rule) # nil
      Veli.valid(nil, rule) # nil

      rule = [type: :integer, nullable: true]
      Veli.valid(5, rule) # nil
      Veli.valid(nil, rule) # {:type, false}

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
          age: [type: :integer, min: 13]
        },
        error: "Not a valid object."
      }
      Veli.valid(%{username: "bob", age: 16}, rule) |> Veli.error() # nil
      Veli.valid(96, rule) |> Veli.error() # "Not a valid object."

  ### More Example
  You can read library tests for more example.
  """

  @default_validators [
    nullable: Veli.Validators.Nullable,
    type: Veli.Validators.Type,
    run: Veli.Validators.Run,
    outside: Veli.Validators.Outside,
    inside: Veli.Validators.Inside,
    min: Veli.Validators.Min,
    max: Veli.Validators.Max,
    match: Veli.Validators.Match
  ]

  @doc """
  Validate a value with rules.
  Returns a keyword list which contains results. You should not process that result yourself. Use `Veli.errors` or `Veli.error` for processing results instead.

  ## Example

      rule = [type: :string, match: ~r/^https?/]
      Veli.valid("wow", rule) |> Veli.error() !== nil
      Veli.valid("https://hex.pm", rule) |> Veli.error() === nil

  More examples can be found in library tests.
  """
  @spec valid(any, keyword | Veli.Types.List | Veli.Types.Map) :: keyword | tuple | nil
  def valid(values, %{rule: rule, error: error} = rules) when is_struct(rules, Veli.Types.List) do
    if is_list(values) do
      values
      |> Enum.with_index()
      |> Enum.map(fn {value, index} -> {index, valid(value, rule)} end)
    else
      [type: error || false]
    end
  end

  def valid(values, %{rule: rule, strict: strict, error: error} = rules)
      when is_struct(rules, Veli.Types.Map) do
    if not (is_map(values) or is_struct(values)) do
      throw(nil)
    end

    rule_keys = Map.keys(rule)
    values_keys = Map.keys(values)

    if strict === true and Enum.sort(rule_keys) !== Enum.sort(values_keys) do
      throw(nil)
    end

    Enum.map(rule_keys, fn key ->
      value = values[key]
      rule = rule[key]

      {key, valid(value, rule)}
    end)
  catch
    _ -> [type: error || false]
  end

  def valid(value, rules) when is_list(rules) do
    init_validator_table()

    rules
    |> Enum.each(fn {atom, rule} ->
      case :ets.lookup(:veli_validators, atom) do
        [{_atom, module} | _other] ->
          case module.valid?(value, rule) do
            nil ->
              throw(nil)

            false ->
              fail_msg = rules[String.to_atom("_" <> Atom.to_string(atom))]
              throw({atom, fail_msg || false})

            _ ->
              :ok
          end

        _ ->
          :ok
      end
    end)

    nil
  catch
    result -> result
  end

  def valid(_value, _rules) do
    raise ArgumentError, message: "Unexpected type for rules."
  end

  @doc """
  Returns all failed validations.

  ## Example

      rule = %Veli.Types.List{rule: [type: :float]}
      Veli.valid([5, 3.2, "how"], rule) |> Veli.errors()
  """
  @spec errors(keyword | tuple) :: keyword
  def errors(result) when is_tuple(result) do
    [result]
  end

  def errors(result) when is_nil(result) do
    []
  end

  def errors(result) do
    result
    |> Enum.map(fn {_atom, value} -> if is_list(value), do: errors(value), else: value end)
    |> List.flatten()
    |> Enum.filter(fn value -> value !== nil end)
  end

  @doc """
  Returns first error from validate result.
  Returns `nil` if everything is valid.

  ## Example

      rule = %Veli.Types.List{rule: [type: :float]}
      Veli.valid([5, 3.2, "how"], rule) |> Veli.error()
  """
  @spec error(keyword | tuple) :: tuple | nil
  def error(result) do
    result
    |> errors
    |> List.first()
  end

  @doc """
  Add a custom validator to validator table.
  Given module must have a function named "valid?".
  Check validators in source code to get more information about implementing your own validator.

  ## Example

      defmodule ModValidator do
        def valid?(value, rule) when is_number(value) do
          rem(value, rule) === 0
        end

        def valid?(_value, _rule) do
          false
        end
      end

      Veli.add_validator(:mod, ModValidator)

      rule = %Veli.Types.List{rule: [nullable: false, type: :integer, mod: 2]}
      Veli.valid([2, 4, 6], rule) |> Veli.error()
  """
  @spec add_validator(atom, module) :: true
  def add_validator(name, module) do
    init_validator_table()
    :ets.insert(:veli_validators, {name, module})
  end

  defp init_validator_table do
    if :ets.whereis(:veli_validators) === :undefined do
      :ets.new(:veli_validators, [:set, :protected, :named_table])

      @default_validators
      |> Enum.each(fn {name, module} ->
        :ets.insert(:veli_validators, {name, module})
      end)
    else
      :ok
    end
  end
end
