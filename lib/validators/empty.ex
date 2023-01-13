defmodule Veli.Validators.Empty do
  @moduledoc """
  Empty value validator.

  ## Example

      rule = [type: :string, empty: true]
      Veli.valid("hello", rule) # valid
      Veli.valid("", rule) # valid

      rule = [type: :string, empty: false]
      Veli.valid("hello", rule) # valid
      Veli.valid("", rule) # not valid
  """

  @spec valid?(any, boolean) :: boolean
  def valid?(value, rule) when is_binary(value) do
    if value === "" and rule === false do
      false
    else
      true
    end
  end

  def valid?(_value, _rule) do
    false
  end
end
