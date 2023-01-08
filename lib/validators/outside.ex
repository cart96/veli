defmodule Veli.Validators.Outside do
  @spec valid?(any, list) :: boolean
  def valid?(value, rule) do
    value not in rule
  end
end
