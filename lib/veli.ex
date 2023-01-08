defmodule Veli do
  @spec valid(any, keyword) :: keyword
  def valid(values, rules) when is_list(values) do
    %{rule: rules} = rules

    values
    |> Enum.with_index()
    |> Enum.map(fn {value, index} -> {index, valid(value, rules)} end)
  end

  def valid(values, rules_map) when is_struct(values) or is_map(values) do
    %{rule: rules_map} = rules_map

    values
    |> Map.keys()
    |> Enum.filter(fn key -> rules_map[key] !== nil end)
    |> Enum.map(fn key ->
      value = values[key]
      rules = rules_map[key]

      cond do
        is_struct(rules, Veli.Types.List) and not is_list(value) ->
          {key, type: false}

        is_struct(rules, Veli.Types.Map) and not (is_map(value) or is_struct(value)) ->
          {key, type: false}

        true ->
          {key, valid(value, rules)}
      end
    end)
  end

  def valid(value, rules) do
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
      {rule_atom, module.valid?(value, rule)}
    end)
  end

  def errors(result) do
    result
    |> Enum.map(fn {atom, value} -> if is_list(value), do: errors(value), else: {atom, value} end)
    |> List.flatten()
    |> Enum.filter(fn {_atom, value} -> value !== true end)
  end

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
