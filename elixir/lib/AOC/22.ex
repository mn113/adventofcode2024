defmodule AOC.Day22 do
  @sixteen_mil 16_777_216

  # Read input as lines of positive integers
  defp read_input do
    File.read!(Path.expand("../inputs/input22.txt"))
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp evolve(num) do # initial secret
    num2 = num
    |> Bitwise.bsl(6) # or * 64
    |> Bitwise.bxor(num)
    |> Bitwise.band(@sixteen_mil - 1) # or Integer.mod(@sixteen_mil)

    num3 = num2
    |> Bitwise.bsr(5) # or div(32)
    |> Bitwise.bxor(num2)
    |> Bitwise.band(@sixteen_mil - 1)

    num3
    |> Bitwise.bsl(11) # or * 2048
    |> Bitwise.bxor(num3)
    |> Bitwise.band(@sixteen_mil - 1)
  end

  defp evolve_times(num, 0), do: num
  defp evolve_times(num, times) do
    evolve_times(evolve(num), times - 1)
  end

  defp evolve_and_collect_times(num, 0, collection), do: collection ++ [num]
  defp evolve_and_collect_times(num, times, collection) do
    evolve_and_collect_times(evolve(num), times - 1, collection ++ [num])
  end

  @doc """
  Calculate the sum of the 2000-times evolved secret for each input
  """
  def part1 do
    read_input()
    |> Enum.map(fn num -> evolve_times(num, 2000) end)
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  @doc """
  Calculate the maximum bananas by finding the optimal slice of 4 deltas preceding all sales
  """
  def part2 do
    # gather the list of {deltas, prices} for each seller
    results = Enum.map(read_input(), fn num ->
      prices = evolve_and_collect_times(num, 2000, []) |> Enum.map(&Integer.mod(&1, 10))
      deltas = Enum.zip(prices, Enum.drop(prices, 1)) |> Enum.map(fn {a, b} -> b - a end)
      {deltas, prices}
    end)

    # build a Map %{slice => total price} covering all results and their delta-slices
    Enum.reduce(results, %{}, fn {deltas, prices}, acc ->
      Enum.reduce((0..1996), %{}, fn i, acc2 ->
        slice = Enum.slice(deltas, i, 4)
        # write the price only the first time the slice is found per result deltas
        Map.put_new(acc2, slice, Enum.at(prices, i + 4))
      end)
      |> Map.filter(fn {_k, v} -> v > 0 end)
      |> Map.merge(acc, fn _k, v1, v2 -> v1 + v2 end)
    end)
    |> Map.values()
    |> Enum.max()
    |> IO.inspect(label: "P2")
  end
end

# P1: 14180628689
# P2: 1690
