defmodule Veli.Validators.Min do
  @spec valid?(binary | maybe_improper_list | number | map, number) :: boolean
  def valid?(value, rule) when is_binary(value) do
    String.length(value) >= rule
  end

  def valid?(value, rule) when is_integer(value) or is_float(value) do
    value >= rule
  end

  def valid?(_value, _rule) do
    true
  end
end
