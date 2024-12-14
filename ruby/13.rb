#!/usr/bin/env ruby

require 'matrix'

@A_press_cost = 3
@B_press_cost = 1

def read_input
    input = File.open("../inputs/input13.txt", "r")
    games = []
    game = {}
    input.each_line do |line|
        /X[+=]?(?<x>\d+), Y[+=]?(?<y>\d+)/ =~ line.chomp.split(":")[1]
        if line.start_with? "Button A"
            game[:A] = Complex(x.to_i, y.to_i)
        elsif line.start_with? "Button B"
            game[:B] = Complex(x.to_i, y.to_i)
        elsif line.start_with? "Prize"
            game[:prize] = Complex(x.to_i, y.to_i)
        else
            games.push(game.dup)
            game = {}
        end
    end
    games
end

# Determinant of a 2x2 matrix is: a*d - b*c
# where layout is:
# [a b]
# [c d]

# Given 2 equations with 2 coefficients:
# ax + by = c
# Ax + By = C

# Denominator matrix D is given by LHS coefficients
# [a b]
# [A B]
# so det_D = a*B - b*A

# Numerator matrix Dx is given by replacing column aA with cC
# [c b]
# [C B]
# so det_Dx = c*B - b*C

# Numerator matrix Dy is given by replacing column bB with cC
# [a c]
# [A C]
# so det_Dy = a*C - c*A

# Then equations' solution is:
# x = det_Dx / det_D
# y = det_Dy / det_D


# eq1: game[:A].real * a_presses + game[:B].real * b_presses = prize.real
# eq2: game[:A].imag * a_presses + game[:B].imag * b_presses = prize.imag
def solve_matrix(game, stupid_factor = 0, presses_limit = 100)
    prize = game[:prize]
    prize += Complex(stupid_factor, stupid_factor)

    det_D = Matrix[ [game[:A].real, game[:B].real], [game[:A].imaginary, game[:B].imaginary] ].det
    det_A = Matrix[ [prize.real, game[:B].real], [prize.imaginary, game[:B].imaginary] ].det
    det_B = Matrix[ [game[:A].real, prize.real], [game[:A].imaginary, prize.imaginary] ].det

    a_presses = det_A.fdiv(det_D)
    b_presses = det_B.fdiv(det_D)

    if (a_presses == a_presses.to_i and b_presses == b_presses.to_i and
        0 <= a_presses and a_presses <= presses_limit and
        0 <= b_presses and b_presses <= presses_limit)
        p "#{a_presses} A presses and #{b_presses} B presses wins"
        return a_presses.to_i * @A_press_cost + b_presses.to_i * @B_press_cost
    else
        return 0
    end
end

@stupid_factor = 10_000_000_000_000

games = read_input()
p "#{games.length} games parsed"
p "Part 1: #{games.map{ |g| solve_matrix(g) }.sum}"
p "Part 2: #{games.map{ |g| solve_matrix(g, @stupid_factor, @stupid_factor) }.sum}"

# P1: 35082
# P2: 82570698600470