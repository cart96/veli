defmodule Veli.Validators.Inside do
  @moduledoc """
  Inside validator.
  
  ## Example
  
      rule = [type: :string, inside: ["value1", "value2"]]
      Veli.valid("value1", rule)
  """

  @spec valid?(any, list) :: boolean
  def valid?(value, rule) do
    value in rule
  end
end
