defmodule Mix.Tasks.Runner do
  use Mix.Task

  @shortdoc "Runs both solution parts for a given day"
  def run(args \\ []) do
    day = Enum.at(args, 0)
    case day do
      "1" ->
        AOC.Day01.part1()
        AOC.Day01.part2()
      "2" ->
        AOC.Day02.part1()
        AOC.Day02.part2()
      "3" ->
        AOC.Day03.part1()
        AOC.Day03.part2()
      "7" ->
        AOC.Day07.part1()
        AOC.Day07.part2()
      "11" ->
        Application.ensure_all_started(:memoize)
        AOC.Day11.part1()
        AOC.Day11.part2()
      _ ->
        IO.puts "Day #{day} not implemented."
    end
  end
end
