defmodule Veli.Validators.Match do
  @moduledoc """
  Match validator.
  Uses regex if match value is a regex sigil. Otherwise compares both values.
  
  ## Example
  
      rule = [type: :string, match: ~r/^https?/]
      Veli.valid("https://example.com", rule)
  """

  @spec valid?(any, any) :: boolean
  def valid?(value, rule) when is_binary(value) and is_struct(rule, Regex) do
    Regex.match?(rule, value)
  end

  def valid?(value, rule) do
    value === rule
  end
end
