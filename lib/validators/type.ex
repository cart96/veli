defmodule Veli.Validators.Type do
  @moduledoc """
  Type validator. Takes an atom that contains type information.

  ## Atoms
  - `:string`
  - `:integer`
  - `:float`
  - `:boolean`

  ## Example

      rule = [type: :integer]
      Veli.valid(2, rule) # valid
      Veli.valid(4.2, rule) # not valid
  """

  @spec valid?(any, atom) :: boolean
  def valid?(value, rule) when is_binary(value) do
    rule === :string
  end

  def valid?(value, rule) when is_integer(value) do
    rule === :integer
  end

  def valid?(value, rule) when is_float(value) do
    rule === :float
  end

  def valid?(value, rule) when is_boolean(value) do
    rule === :boolean
  end

  def valid?(_value, _rule) do
    false
  end
end
