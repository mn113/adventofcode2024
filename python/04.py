#! /usr/bin/env python3

# Load grid into nested array:
with open('../inputs/input04.txt') as fp:
    grid = [[char for char in line_str.strip()] for line_str in fp.readlines()]
ydim = len(grid)
xdim = len(grid[0])

##
# Part 1
# search for the word 'XMAS' in 8 directions
#
found_xmases = []

for y in range(ydim):
    for x in range(xdim):
        if grid[y][x] == 'X':
            for dy in [-1, 0, 1]:
                for dx in [-1, 0, 1]:
                    x1, y1 = x + dx, y + dy
                    x2, y2 = x1 + dx, y1 + dy
                    x3, y3 = x2 + dx, y2 + dy

                    # skip deltas that stay in one spot or go out of bounds
                    if dx == 0 and dy == 0:
                        continue
                    if x3 < 0 or x3 >= xdim or y3 < 0 or y3 >= ydim:
                        continue

                    # check next 3 letters
                    if grid[y1][x1] == 'M':
                        if grid[y2][x2] == 'A':
                            if grid[y3][x3] == 'S':
                                found_xmases.append([(x, y), (x1, y1), (x2, y2), (x3, y3)])

print("Part 1:", len(found_xmases))

##
# Part 2
# search for the word 'MAS' crossing another 'MAS' in an X-shape
#
found_mas_mas = 0

for y in range(1, ydim - 1):
    for x in range(1, xdim - 1):
        if grid[y][x] == 'A':
            # check for MAS occurring on 2 diagonals
            corners = [(x+1, y+1), (x+1, y-1), (x-1, y-1), (x-1, y+1)]
            corner_letters = [grid[c[1]][c[0]] for c in corners]
            corner_letters_str = "".join(corner_letters)
            # ignore MAM & SAS:
            if corner_letters_str in ['MSMS', 'SMSM']:
                continue
            if sorted(corner_letters) == ['M', 'M', 'S', 'S']:
                found_mas_mas += 1

print("Part 2:", found_mas_mas)

# P1: 2644
# P2: 1952
