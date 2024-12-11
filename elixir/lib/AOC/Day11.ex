defmodule AOC.Day11 do
  use Memoize

  # Read input line; split to integer list
  defp read_input do
    File.read!(Path.expand("../inputs/input11.txt"))
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  # Transform a stone:
  # 0 -> [1]
  # even digits -> [a, b]
  # odd digits -> [a * 2024]
  # memoize probably was overkill
  defmemo transform_stone(val) do
    if val == 0 do
      [1]
    else
      digits = Integer.digits(val)
      if rem(length(digits), 2) == 0 do
        mid = div(length(digits), 2)
        [
          Integer.undigits(Enum.take(digits, mid)),
          Integer.undigits(Enum.drop(digits, mid))
        ]
      else
        [val * 2024]
      end
    end
  end

  @doc """
  Count the stones after 25 blinks
  """
  def part1 do
    read_input()
    |> then(fn stones -> Map.from_keys(stones, 1) end)
    |> do_smart_loops(25)
    |> Map.values()
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  # One by one, update the hash with the results of transforming the stones in the hash
  defp do_smart_loop(stones_hash) do
    stones_list = Map.to_list(stones_hash)
    fresh_stones_hash = %{}

    Enum.reduce(stones_list, fresh_stones_hash, fn {stone, count}, acc1 ->
      ts = transform_stone(stone)

      Enum.reduce(ts, acc1, fn new_stone, acc2 ->
        Map.update(acc2, new_stone, count, &(&1 + count))
      end)
    end)
  end

  # Loop n times
  defp do_smart_loops(stones_hash, 0), do: stones_hash
  defp do_smart_loops(stones_hash, n) do
    do_smart_loops(do_smart_loop(stones_hash), n - 1)
  end

  @doc """
  Count the stones after 75 blinks
  """
  def part2 do
    read_input()
    |> then(fn stones -> Map.from_keys(stones, 1) end)
    |> do_smart_loops(75)
    |> Map.values()
    |> Enum.sum
    |> IO.inspect(label: "P2")
  end
end

# P1: 239714
# P2: 284973560658514