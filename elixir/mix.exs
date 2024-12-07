defmodule AOC.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.0.1",
      elixir: "~> 1.14",
      deps: deps()
    ]
  end

#   defp aliases do
#     [
#       rc: "recompile"
#     ]
#   end

  defp deps do
    [
      {:comb, git: "https://github.com/tallakt/comb.git", tag: "master"}
    ]
  end
end
