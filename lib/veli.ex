defmodule Veli do
  def valid(value, rules) do
    {:ok, modules} = :application.get_key(:veli, :modules)

    modules
    |> Enum.filter(fn module ->
      Enum.fetch(module_to_path(module), 2) === {:ok, "Validators"}
    end)
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

  defp module_to_path(module) do
    String.split(to_string(module), ".")
  end

  defp validator_to_atom(module) do
    module
    |> module_to_path
    |> Enum.fetch!(3)
    |> String.downcase()
    |> String.to_existing_atom()
  end
end
