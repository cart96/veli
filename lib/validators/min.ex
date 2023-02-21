defmodule Veli.Validators.Min do
  @moduledoc """
  Min validator.
  
  ## Example
  
      rule = [min: 5]
      Veli.valid("valid length", rule)
      Veli.valid(1, rule) # invalid
  """

  @spec valid?(any, number) :: boolean
  def valid?(value, rule) when is_binary(value) do
    String.length(value) >= rule
  end

  def valid?(value, rule) when is_integer(value) or is_float(value) do
    value >= rule
  end

  def valid?(_value, _rule) do
    false
  end
end
