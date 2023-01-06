defmodule Veli do
  @moduledoc """
  Documentation for `Veli`.
  """

  @spec validate_form(map, map) :: list
  def validate_form(form, rules) do
    form
    |> Enum.map(fn {key, value} ->
      {key, check_value({:type, value}, rules[key])}
    end)
  end

  @spec validate(any, map) :: :match_error | :max_error | :min_error | :ok | :type_error
  def validate(value, rule) do
    check_value({:type, value}, rule)
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
      :ok
    end
  end
end
