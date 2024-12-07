defmodule AOC.Day01 do
  # Read input as lines
  defp read_input do
    File.read!(Path.expand("../inputs/input01.txt"))
    |> String.split("\n")
  end

  # Convert lines to integer lists
  defp to_integer_lists_by_column(input) do
    lines = input
    |> Enum.map(fn line ->
        Regex.run(~r/^(\d+)\D+(\d+)$/, String.trim(line))
        |> Enum.drop(1)
        |> Enum.map(&String.to_integer/1)
    end)

    col1 = Enum.map(lines, fn [a, _] -> a end)
    col2 = Enum.map(lines, fn [_, b] -> b end)
    [col1, col2]
  end

  @doc """
  Sort 2 lists ascending, find diff between each number pir, sum them.
  """
  def part1 do
    [col1, col2] = to_integer_lists_by_column(read_input())
    Enum.zip(Enum.sort(col1), Enum.sort(col2))
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  @doc """
  Find similarity: sum of count of col2 appearances of each col1 value
  """
  def part2 do
    [col1, col2] = to_integer_lists_by_column(read_input())
    col1
    |> Enum.map(fn a -> a * Enum.count(col2, fn b -> b == a end) end)
    |> Enum.sum
    |> IO.inspect(label: "P2")
  end
end

# P1: 2769675
# P2: 24643097