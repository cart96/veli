defmodule Veli.Types.Map do
  @moduledoc """
  Custom struct for validator map lookup.

  ## Strict
  If strict is `true`, it will also check all keys in given data and returns type error if they are not same.

  ## Example

      rule = %Veli.Types.Map{
        rule: %{
          username: [type: :string, min: 3, max: 32],
          password: [type: :string, min: 8, max: 72],
          accepted: [type: :boolean, match: true]
        },
        strict: true,
        error: "Value must be a map"
      }
  """

  @enforce_keys [:rule]
  defstruct [:rule, :strict, :error]
end
