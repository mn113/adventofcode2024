defmodule AOC.Day17 do
  @moduledoc """
  Process the inputs for an opcode computer working on 3 registers and 1 output array
  """

  @instructions %{
    0 => :adv, # divide regA by 2 ** combo operand, truncate and store in regA
    1 => :bxl, # bitwise XOR regB with literal operand, store in regB
    2 => :bst, # combo operand % 8, store in regB
    3 => :jnz, # if regA != 0, jump instruction pointer to literal operand
    4 => :bxc, # bitwise XOR regB with regC, store in regC
    5 => :out, # combo operand % 8, output it
    6 => :bdv, # divide regA by 2 ** combo operand, truncate and store in regB
    7 => :cdv  # divide regA by 2 ** combo operand, truncate and store in regC
  }

  # Read input file; split to register values and program input
  defp read_input do
    File.read!(Path.expand("../inputs/input17.txt"))
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index
    |> Enum.map(fn {line,i} ->
      cond do
        i <= 2 -> parse_register_line(line)
        i == 4 -> parse_program_line(line)
        true -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_register_line(line) do
    line
    |> String.slice(12..-1//1)
    |> String.trim()
    |> String.to_integer()
  end

  defp parse_program_line(line) do
    line
    |> String.slice(9..-1//1)
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp get_combo_operand(num, {regA, regB, regC}) do
    case num do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
      4 -> regA
      5 -> regB
      6 -> regC
      7 -> :error # 7 can be queried, but its value will never need to be used
    end
  end

  defp process_opcode(opcode, literal_operand, {regA, regB, regC}) do
    decoded_opcode = Map.get(@instructions, opcode)
    combo_operand = get_combo_operand(literal_operand, {regA, regB, regC} )

    regA = case decoded_opcode do
      # opcode 0
      :adv -> div(regA, 2 ** combo_operand)
      _ -> regA
    end
    regB = case decoded_opcode do
      # opcode 1
      :bxl -> Bitwise.bxor(regB, literal_operand)
      # opcode 2
      :bst -> Integer.mod(combo_operand, 8)
      # opcode 4
      :bxc -> Bitwise.bxor(regB, regC)
      # opcode 6
      :bdv -> div(regA, 2 ** combo_operand)
      _ -> regB
    end
    regC = case decoded_opcode do
      # opcode 7
      :cdv -> div(regA, 2 ** combo_operand)
      _ -> regC
    end
    output = case decoded_opcode do
      # opcode 3
      :jnz -> :jump_if_regA_not_zero
      # opcode 5
      :out -> Integer.mod(combo_operand, 8)
      _ -> nil
    end

    {output, {regA, regB, regC}}
  end

  defp process_program(program, pointer, registers, outputs \\ []) do
    # halt condition: for a program of length 6, highest valid pointer is index 4
    if pointer > length(program) - 2 do
      #IO.inspect(outputs, label: "done") # never reached!
      outputs
    else
      # The first 2 values after the pointer are the opcode and the literal operand
      opcode = Enum.at(program, pointer)
      literal_operand = Enum.at(program, pointer + 1)

      {new_output, new_registers} = process_opcode(opcode, literal_operand, registers)
      #IO.inspect([pointer, opcode, literal_operand, new_output, new_registers, outputs], label: "ptr, opcode, literal, output, regs, outputs")

      # go again
      regA = elem(registers, 0)
      cond do
        # jump causes pointer to be set to current literal operand; in all other cases pointer increases by 2
        new_output == :jump_if_regA_not_zero and regA != 0 ->
          process_program(program, literal_operand, new_registers, outputs)
        new_output != :jump_if_regA_not_zero and new_output != nil ->
          process_program(program, pointer + 2, new_registers, outputs ++ [new_output])
        true ->
          process_program(program, pointer + 2, new_registers, outputs)
      end
    end
  end

  @doc """
  Run the opcode program and collect its output
  """
  def part1 do
    read_input()
    |> then(fn [regA, regB, regC, program] ->
      # begin recursive process until outputs are yielded
      process_program(program, 0, {regA, regB, regC})
    end)
    |> Enum.join(",")
    |> IO.inspect(label: "P1")
  end

  @doc """
  Find the initial regA value which outputs the input
  """
  def part2 do
    read_input()
  end
end

# P1: 1,3,5,1,7,2,5,1,6
# P2: