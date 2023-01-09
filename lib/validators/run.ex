defmodule Veli.Validators.Run do
  @moduledoc """
  Allows you to add custom validator. Any other value than `true` will computed as `false`.

  ## Example

      rule = [type: :integer, run: fn x -> rem(x, 2) === 0 end]
      Veli.valid(2, rule) # valid
      Veli.valid(3, rule) # not valid
  """

  @spec valid?(any, function) :: boolean
  def valid?(value, rule) do
    rule.(value) === true
  end
end
