defmodule Veli do
  @spec valid(any, keyword) :: keyword
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

  @spec errors(keyword) :: keyword
  def errors(result) do
    result
    |> Enum.map(fn {atom, value} -> if is_list(value), do: errors(value), else: {atom, value} end)
    |> List.flatten()
    |> Enum.filter(fn {_atom, value} -> value !== true end)
  end

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
