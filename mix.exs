defmodule ExMagicZig.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_magic_zig,
      version: "0.1.0",
      elixir: "~> 1.18",
      description: "libmagic bindings",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      preferred_cli_env: [docs: :docs, "hex.publish": :docs]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:zigler, git: "https://github.com/E-xyza/zigler/", tag: "0.15.1", runtime: false},
      {:ex_doc, "~> 0.34", only: :docs}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ndrean/ex_magic_zig"},
      name: :ex_magic_zig
    ]
  end

  defp docs do
    [
      main: "ExMagicZig",
      extras: ["README.md"]
    ]
  end
end
