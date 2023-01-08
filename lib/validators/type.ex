defmodule Veli.Validators.Type do
  @spec valid?(boolean | binary | maybe_improper_list | number | map, atom) :: boolean
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

  def valid?(value, rule) when is_list(value) do
    rule === :list
  end

  def valid?(value, rule) when is_map(value) do
    rule === :map
  end

  def valid?(_value, _rule) do
    true
  end
end
