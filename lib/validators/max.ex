defmodule Veli.Validators.Max do
  @spec valid?(binary | maybe_improper_list | number | map, number) :: boolean
  def valid?(value, rule) when is_binary(value) do
    String.length(value) <= rule
  end

  def valid?(value, rule) when is_integer(value) or is_float(value) do
    value <= rule
  end

  def valid?(value, rule) when is_list(value) do
    :erlang.length(value) <= rule
  end

  def valid?(value, rule) when is_map(value) do
    :erlang.length(Map.keys(value)) <= rule
  end

  def valid?(_value, _rule) do
    true
  end
end
