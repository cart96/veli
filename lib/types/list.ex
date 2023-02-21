defmodule Veli.Types.List do
  @moduledoc """
  Custom struct for validator list lookup.
  
  ## Example
  
      rule = %Veli.Types.List{
        rule: [type: :integer, _type: "List member must be an integer"],
        error: "Value must be a list"
      }
  """

  @enforce_keys [:rule]
  defstruct [:rule, :error]
end
