defmodule Veli.Validators.Run do
  @spec valid?(any, function) :: boolean
  def valid?(value, rule) do
    rule.(value) === true
  end
end
