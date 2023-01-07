defmodule Veli do
  @moduledoc """
  Veli (**V**alidation in **eli**xir) is a simple validation library for elixir.

  ## Rule

  Rule is a keyword list that contains some rules for validation.

  A rule has these options:
  - `type`: for validating types / affects some other rules like `min` and `max`. Supports following types:
      - `string`
      - `integer`
      - `number`
      - `bool`
      - `list`
      - `map`
  - `min`: Minimum value to accept.
      - for `number` and `integer`, it checks the number.
      - for `string`, it checks string length.
      - for `list`, it checks list length.
      - for `map`, it checks key length.
  - `max`: Same with `min` rule but for maximum values.
  - `match`: For matching a value.
      - for `string`, it uses regex to match.
      - for any other type, it will just compare both values.
  - `run`: Allows you to add custom filtering function inside it that returns a boolean. If it returns false, validation will fail.

  Here is an example for rule defination.

      username_rule = [type: :string, min: 3, max: 32, match: ~r/^[a-zA-Z0-9_]*$/]

  And for validating forms:

      form_rules = %{
        "username" => [type: :string, min: 3, max: 32, match: ~r/^[a-zA-Z0-9_]*$/],
        "age" => [type: :integer, min: 13]
      }

  """

  @doc """
  Validate a form with rules.

  Returns list of results which contains a tuple that includes key with result.

  ## Example

      iex(1)> form = %{"username" => "john", "age" => 17}
      %{"age" => 17, "username" => "john"}
      iex(2)> rules = %{"username" => [type: :string, min: 3, max: 32, match: ~r/^[a-zA-Z0-9_]*$/], "age" => [type: :integer, min: 13]}
      %{
        "age" => [type: :integer, min: 13],
        "username" => [type: :string, min: 3, max: 32, match: ~r/^[a-zA-Z0-9_]*$/]
      }
      iex(3)> Veli.validate_form(form, rules)
      [{"age", :ok}, {"username", :ok}]
      iex(4)> form = %{form | "age" => 10}
      %{"age" => 10, "username" => "john"}
      iex(5)> Veli.validate_form(form, rules)
      [{"age", :min_error}, {"username", :ok}]

  """
  @spec validate_form(map, map) :: list
  def validate_form(form, rules) do
    form
    |> Enum.map(fn {key, value} -> {key, check_value({:type, value}, rules[key])} end)
  end

  @doc """
  Validate list elements with a rule

  Returns list of results which contains a tuple that includes index with result.

  ## Example

      iex(1)> rule = [type: :integer, run: fn value -> rem(value, 2) == 0 end]
      [type: :integer, max: 100]
      iex(2)> Veli.validate_list([4, 6, 8, 10], rule) |> Veli.get_error()
      nil
      iex(3)> Veli.validate([4, 3, 8], rule) |> Veli.get_error()
      {1, :run_error}

  """
  @spec validate_list(list, keyword) :: list
  def validate_list(list, rule) do
    list
    |> Enum.with_index()
    |> Enum.map(fn {value, index} -> {index, check_value({:type, value}, rule)} end)
  end

  @doc """
  Validate a value with rule.

  Returns an atom.

  ## Examples

  Simple usage

      iex(1)> rule = [type: :integer, max: 100]
      [type: :integer, max: 100]
      iex(2)> Veli.validate(96, rule)
      :ok
      iex(3)> Veli.validate(101, rule)
      :max_error

  Adding custom filtering functions

      iex(1)> rule = [type: :string, run: fn value -> String.reverse(value) === value end]
      [type: :string, run: #Function<42.3316493/1 in :erl_eval.expr/6>]
      iex(2)> Veli.validate("wow", rule)
      :ok
      iex(3)> Veli.validate("hello", rule)
      :run_error

  """
  @spec validate(any, keyword) :: :match_error | :max_error | :min_error | :ok | :type_error
  def validate(value, rule) do
    check_value({:type, value}, rule)
  end

  @doc """
  An helper function for validate_form/2 that finds first error from form validation result.

  Returns first error from form validation result. `nil` if success.

  ## Example

      iex(1)> form = %{"username" => "james", "age" => 10}
      %{"age" => 10, "username" => "james"}
      iex(2)> rules = %{"username" => [type: :string], "age" => [type: :integer, min: 13]}
      %{
        "age" => [type: :integer, min: 13],
        "username" => [type: :string]
      }
      iex(3)> Veli.validate_form(form, rules)
      [{"age", :min_error}, {"username", :ok}]
      iex(4)> Veli.validate_form(form, rules) |> Veli.get_error()
      {"age", :min_error}
      iex(5)> form = %{form | "age" => 20}
      %{"age" => 20, "username" => "james"}
      iex(6)> Veli.validate_form(form, rules) |> Veli.get_error()
      nil

  """
  @spec get_error(list) :: tuple | nil
  def get_error(result) do
    result
    |> Enum.filter(fn {_, status} -> status !== :ok end)
    |> List.first()
  end

  defp check_value({:type, value}, rule) do
    result =
      case rule[:type] do
        :string ->
          is_binary(value)

        :integer ->
          is_integer(value)

        :number ->
          is_number(value)

        :bool ->
          is_boolean(value)

        :list ->
          is_list(value)

        :map ->
          is_map(value)

        _ ->
          false
      end

    if result === false and rule[:type] !== nil do
      :type_error
    else
      check_value({:min, value}, rule)
    end
  end

  defp check_value({:min, value}, rule) do
    result =
      case rule[:type] do
        :string ->
          String.length(value) >= rule[:min]

        :integer ->
          value >= rule[:min]

        :number ->
          value >= rule[:min]

        :list ->
          :erlang.length(value) >= rule[:min]

        :map ->
          Map.keys(value) |> :erlang.length() >= rule[:min]

        _ ->
          false
      end

    if result === false and rule[:min] !== nil do
      :min_error
    else
      check_value({:max, value}, rule)
    end
  end

  defp check_value({:max, value}, rule) do
    result =
      case rule[:type] do
        :string ->
          String.length(value) <= rule[:max]

        :integer ->
          value <= rule[:max]

        :number ->
          value <= rule[:max]

        :list ->
          :erlang.length(value) <= rule[:max]

        :map ->
          Map.keys(value) |> :erlang.length() <= rule[:max]

        _ ->
          false
      end

    if result === false and rule[:max] !== nil do
      :max_error
    else
      check_value({:match, value}, rule)
    end
  end

  defp check_value({:match, value}, rule) do
    result =
      case rule[:type] do
        :string ->
          Regex.match?(rule[:match] || ~r//, value)

        _ ->
          value === rule[:match]
      end

    if result === false and rule[:match] !== nil do
      :match_error
    else
      check_value({:run, value}, rule)
    end
  end

  defp check_value({:run, value}, rule) do
    if rule[:run] !== nil and rule[:run].(value) === false do
      :run_error
    else
      :ok
    end
  end
end
