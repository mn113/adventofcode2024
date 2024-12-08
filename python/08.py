#! /usr/bin/env python3

SPACE = '.'

# Load grid into nested array:
with open('../inputs/input08.txt') as fp:
    grid = [[char for char in line_str.strip()] for line_str in fp.readlines()]
ydim = len(grid)
xdim = len(grid[0])

nodes_by_char = {}

# find nodes
for y in range(ydim):
    for x in range(xdim):
        char = grid[y][x]
        if char != SPACE:
            if char not in nodes_by_char:
                nodes_by_char[char] = []
            nodes_by_char[char].append((y,x))


def solve(min_antinode_reach, max_antinode_reach):
    all_antinodes = set()
    for char in nodes_by_char:
        nodes = nodes_by_char[char]
        # consider all combinations of 2 different nodes
        for n1 in nodes:
            for n2 in nodes:
                if n1 == n2:
                    continue
                y1, x1 = n1
                y2, x2 = n2
                delta = (y2 - y1, x2 - x1)
                # reach ahead to find each harmonic antinode
                reach = min_antinode_reach
                while reach < max_antinode_reach:
                    y3 = y2 + (delta[0] * reach)
                    x3 = x2 + (delta[1] * reach)
                    if y3 < 0 or y3 >= ydim or x3 < 0 or x3 >= xdim:
                        # force search to stop in this direction
                        reach = max_antinode_reach
                        break
                    antinode = (y3, x3)
                    all_antinodes.add(antinode)
                    reach += 1

    return len(all_antinodes)


print("Part 1:", solve(1, 2))
print("Part 2:", solve(0, max(ydim, xdim)))

# P1: 214
# P2: 809
