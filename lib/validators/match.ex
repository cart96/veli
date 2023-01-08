defmodule Veli.Validators.Match do
  @spec valid?(any, any) :: boolean
  def valid?(value, rule) when is_binary(value) do
    Regex.match?(rule, value)
  end

  def valid?(value, rule) do
    value === rule
  end
end
