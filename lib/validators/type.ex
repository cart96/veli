defmodule Veli.Validators.Type do
  @moduledoc """
  Type validator. Takes a tuple that contains a atom with nullable boolean.

  ## Atoms
  - `:string`
  - `:integer`
  - `:float`
  - `:boolean`

  ## Example

      rule = [type: {:integer, true}]
      Veli.valid(2, rule) # valid
      Veli.valid(nil, rule) # valid
      Veli.valid(4.2, rule) # not valid
  """

  @spec valid?(boolean | binary | maybe_improper_list | number | map, atom) :: boolean
  def valid?(value, {rule, _nullable}) when is_binary(value) do
    rule === :string
  end

  def valid?(value, {rule, _nullable}) when is_integer(value) do
    rule === :integer
  end

  def valid?(value, {rule, _nullable}) when is_float(value) do
    rule === :float
  end

  def valid?(value, {rule, _nullable}) when is_boolean(value) do
    rule === :boolean
  end

  def valid?(value, {_rule, nullable}) when is_nil(value) do
    nullable
  end

  def valid?(_value, _rule) do
    false
  end
end
