defmodule AOC.Day02 do
  # Read input as lines
  defp read_input do
    File.read!(Path.expand("../inputs/input02.txt"))
    |> String.split("\n")
    |> Enum.map(fn line ->
      String.split(line, " ")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  # Check if line is uniformly increasing or decreasing by steps of 1-3
  defp is_safe(line) do
    looks_increasing = Enum.at(line, 0) < Enum.at(line, 1)
    looks_decreasing = Enum.at(line, 0) > Enum.at(line, 1)

    if !looks_increasing and !looks_decreasing do
      false
    else
      checks = for {a, b} <- Enum.zip(line, Enum.drop(line, 1)) do
        if looks_decreasing,
        do: a - b >=1 and a - b <= 3,
        else: b - a >=1 and b - a <= 3
      end
      Enum.all?(checks)
    end
  end

  # Get line variants with a single step removed
  defp get_variants(line) do
    n = length(line)
    for i <- 0..(n-1) do
      Enum.take(line, i) ++ Enum.drop(line, i+1)
    end
  end

  @doc """
  Count the lines which are safe
  """
  def part1 do
    read_input()
    |> Enum.filter(&is_safe/1)
    |> Enum.count
    |> IO.inspect(label: "P1")
  end

  @doc """
  Count the lines which are safe if any one step can be removed
  """
  def part2 do
    read_input()
    |> Enum.map(&get_variants/1)
    |> Enum.filter(fn variants -> Enum.any?(variants, &is_safe/1) end)
    |> Enum.count
    |> IO.inspect(label: "P2")
  end
end

# P1: 279
# P1: 343