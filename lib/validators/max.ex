defmodule Veli.Validators.Max do
  @moduledoc """
  Max validator.
  
  ## Example
  
      rule = [max: 20]
      Veli.valid("valid length", rule)
      Veli.valid(30, rule) # invalid
  """

  @spec valid?(any, number) :: boolean
  def valid?(value, rule) when is_binary(value) do
    String.length(value) <= rule
  end

  def valid?(value, rule) when is_integer(value) or is_float(value) do
    value <= rule
  end

  def valid?(_value, _rule) do
    false
  end
end
