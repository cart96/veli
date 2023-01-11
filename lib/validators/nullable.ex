defmodule Veli.Validators.Nullable do
  @moduledoc """
  Nullable validator.

  ## Example

      rule = [type: :integer, nullable: true]
      Veli.valid(2, rule) # valid
      Veli.valid(nil, rule) # valid
      Veli.valid(4.2, rule) # not valid
  """

  @spec valid?(any, boolean) :: boolean
  def valid?(value, nullable) when is_nil(value) do
    if nullable === true do
      nil
    else
      false
    end
  end

  def valid?(_value, _rule) do
    true
  end
end
