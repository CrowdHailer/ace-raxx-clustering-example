defmodule AceRaxxClusterExample.Mixfile do
  use Mix.Project

  def project do
    [app: :ace_raxx_cluster_example,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger],
     mod: {AceRaxxClusterExample, []}]
  end

  defp deps do
    [
      {:ace, "0.6.3"},
      {:raxx, "0.4.0"}
    ]
  end
end
