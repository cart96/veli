defmodule Veli.Build do
  @moduledoc """
  This macro allows you define rule and add a validator function inside of it.
  
      defmodule Validators.Users do
        use Veli.Build, %Veli.Types.Map{
          rule: %{
            "username" => [type: :string, min: 3, max: 32],
            "age" => [type: :integer, min: 13]
          },
          strict: true
        }
      end
  
      Validators.Users.valid(%{"username" => "hello", "age" => 17})
      |> Veli.error
  """

  defmacro __using__(rule) do
    quote bind_quoted: [rule: rule] do
      def valid(data) do
        Veli.valid(data, unquote(Macro.escape(rule)))
      end
    end
  end
end
