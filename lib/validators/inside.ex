defmodule Veli.Validators.Inside do
  @spec valid?(any, list) :: boolean
  def valid?(value, rule) do
    value in rule
  end
end
