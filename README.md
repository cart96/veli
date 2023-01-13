# Veli

Data validation library for Elixir.

## Installation

the package can be installed by adding `veli` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:veli, "~> 0.2.5"}
  ]
end
```

## Documentation

Documentation is avaible at [HexDocs](https://hexdocs.pm/veli).

## Example

The following example taken from veli tests.

```ex
form_validator = %Veli.Types.Map{
  rule: %{
    "username" => [
      # Validation
      nullable: false,
      type: :string,
      min: 3,
      max: 32,
      match: ~r/^[a-zA-Z0-9_]*$/,
      # Errors
      _nullable: "Username field not found.",
      _type: "Username must be a string.",
      _min: "Username is too short.",
      _max: "Username is too long.",
      _match: "Username must only contains alphanumeric characters."
    ],
    "age" => [
      # Validation
      nullable: false,
      type: :integer,
      min: 13,
      # Errors
      _nullable: "Age field not found.",
      _type: "Age must be an integer.",
      _min: "Age must be at least 13."
    ]
  },
  error: "Form must be an object."
}

form = %{"username" => "john", "age" => 16}
Veli.valid(form, form_validator)
```

## Community Validators

This list contains validators built for Veli.

- [VeliTurnstile](https://github.com/cart96/veli_turnstile): Cloudflare Turnstile validator for Veli

## Contributing

Please don't send any pull request to main branch.

- You can send pull request to main branch only for adding community validators.

You can report bugs or request features [here](https://github.com/cart96/veli/issues).

Always use `mix format` before sending a pull request.

## License

Released under the MIT License.
