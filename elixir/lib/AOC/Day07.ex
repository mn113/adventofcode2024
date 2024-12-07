defmodule AOC.Day07 do
  import Comb

  # Read input as lines; split to integer lists
  defp read_input do
    File.read!(Path.expand("../inputs/input07.txt"))
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(": ")
      |> then(fn [target, values] ->
        [
          String.to_integer(target),
          String.split(values, " ") |> Enum.map(&String.to_integer/1)
        ]
      end)
    end)
  end

  # compute one step
  defp compute_step(initial, op, value) do
    case op do
      :add -> initial + value
      :mul -> initial * value
      :concat -> String.to_integer(to_string(initial) <> to_string(value))
    end
  end

  # compute the productsum of the values using the chosen operators
  defp compute(values, operators, target) do
    [first | rest] = values
    0..(length(operators) - 1)
    |> Enum.reduce_while(first, fn i, acc ->
      new_acc = compute_step(acc, Enum.at(operators, i), Enum.at(rest, i))
      if new_acc > target,
        do: {:halt, 0},
        else: {:cont, new_acc}
    end)
  end

  # return 0 if not solvable, target value if solvable
  defp try_solve(line, use_concat) do
    [target, values] = line
    # 2 operarors in play
    operator_selections = selections([:add, :mul], length(values) - 1)
    solvable_with_2 = Enum.any?(operator_selections, fn ops ->
      compute(values, ops, target) == target
    end)
    # 3 operarors in play - much slower
    solvable_with_3 = if !solvable_with_2 && use_concat do
      operator_selections2 = selections([:add, :mul, :concat], length(values) - 1)
      Enum.any?(operator_selections2, fn ops ->
        compute(values, ops, target) == target
      end)
    end
    if solvable_with_2 || solvable_with_3, do: target, else: 0
  end

  @doc """
  Sum the solvable targets (operators: *, +)
  """
  def part1 do
    read_input()
    |> Enum.map(&(try_solve(&1, false)))
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  @doc """
  Sum the solvable targets (operators: *, +, concatenation)
  """
  def part2 do
    read_input()
    |> Enum.map(&(try_solve(&1, true)))
    |> Enum.sum
    |> IO.inspect(label: "P2")
  end
end

# P1: 2314935962622
# P2: 401477450831495
