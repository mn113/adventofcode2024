defmodule Day03 do
  @count 1
  @nocount 0
  @turnon 1
  @turnoff -1

  # Read input as lines; concatenate to a single line
  defp read_input do
    File.read!(Path.expand("../inputs/input03.txt"))
    |> String.replace("\n", "___newline___")
  end

  # Parse all the valid "mul(\d,\d)" substrings out of the line
  defp re_parse(line) do
    Regex.scan(~r/(do\(\))|(don't\(\))|(mul\((\d{1,3}),(\d{1,3})\))/, line)
    |> Enum.map(fn [head | tail] ->
      cond do
        String.match?(head, ~r/mul/) -> [@count, String.to_integer(Enum.at(tail, 3)), String.to_integer(Enum.at(tail, 4))]
        String.match?(head, ~r/don't\(\)/) -> [@nocount, @turnoff, @nocount]
        String.match?(head, ~r/do\(\)/) -> [@nocount, @turnon, @nocount]
      end
    end)
  end

  @doc """
  Sum the sums of products of the lines after parsing out the "mul(\d,\d)" substrings
  """
  def part1 do
    read_input()
    |> re_parse
    |> Enum.map(fn parts -> parts
      |> Enum.reduce(fn x, acc -> x * acc end)
    end)
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  @doc """
  Sum the sums of products of the lines taking into account the "mul(\d,\d)", "do()", and "don't()" substrings
  """
  def part2 do
    tracker = %{value: 0, counting: true}

    read_input()
    |> re_parse
    |> Enum.reduce(tracker, fn [a, b, c], acc ->
      cond do
        a == @nocount && b == @turnoff -> Map.update!(acc, :counting, fn _ -> false end)
        a == @nocount && b == @turnon -> Map.update!(acc, :counting, fn _ -> true end)
        a == @count && acc.counting -> Map.update!(acc, :value, fn _ -> acc.value + (b * c) end)
        a == @count && !acc.counting -> acc
      end
    end)
    |> then(fn x -> x.value end)
    |> IO.inspect(label: "P2")
  end
end

# P1: 174103751
# P2: 100411201