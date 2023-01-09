defmodule Veli.Validators.Outside do
  @moduledoc """
  Outside validator.

  ## Example

      rule = [type: :integer, outside: [0, 2, 4, 8]]
      Veli.valid(12, rule) # valid
      Veli.valid(0, rule) # not valid
  """

  @spec valid?(any, list) :: boolean
  def valid?(value, rule) do
    value not in rule
  end
end
