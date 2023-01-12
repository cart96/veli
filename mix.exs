defmodule Veli.MixProject do
  use Mix.Project

  @version "0.2.3"
  @source_url "https://github.com/cart96/veli"

  def project() do
    [
      app: :veli,
      version: @version,
      elixir: "~> 1.8",
      consolidate_protocols: Mix.env() != :test,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Veli",
      source_url: @source_url
    ]
  end

  def application() do
    []
  end

  defp deps() do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Data validation library for Elixir."
  end

  defp package() do
    [
      name: "veli",
      licenses: ["MIT License"],
      links: %{"GitHub" => @source_url},
      maintainers: ["icecat696 (cart96)"]
    ]
  end
end
