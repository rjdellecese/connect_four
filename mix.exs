defmodule ConnectFour.MixProject do
  use Mix.Project

  def project do
    [
      app: :connect_four,
      version: "0.1.4",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Testing
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.circle": :test
      ],

      # Documentation
      name: "Connect Four",
      description: "A fast Connect Four game engine.",
      source_url: "https://github.com/rjdellecese/connect_four",
      homepage_url: "https://github.com/rjdellecese/connect_four",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.1.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:junit_formatter, "~> 3.0", only: :test},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["RJ Dellecese"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rjdellecese/connect_four"}
    ]
  end
end
