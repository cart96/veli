defmodule Veli.Validators.Match do
  @spec valid?(any, any) :: boolean
  def valid?(value, rule) when is_binary(value) do
    if is_struct(rule, Regex) do
      Regex.match?(rule, value)
    else
      false
    end
  end

  def valid?(value, rule) do
    value === rule
  end
end
