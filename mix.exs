defmodule MixGenReleaseConfig.MixProject do
  use Mix.Project

  def project do
    [
      app: :mix_gen_release_config,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test]}
    ]
  end
end
