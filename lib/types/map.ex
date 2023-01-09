defmodule Veli.Types.Map do
  @moduledoc """
  Custom struct for validator map lookup.

  ## Example

      rule = %Veli.Types.Map{
        rule: %{
          username: [type: :string, min: 3, max: 32],
          password: [type: :string, min: 8, max: 72],
          accepted: [type: :boolean, match: true]
        },
        error: "Value must be a map"
      }
  """

  @enforce_keys [:rule]
  defstruct [:rule, :error]
end
