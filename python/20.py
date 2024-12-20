#! /usr/bin/env python3

import functools

START_SYM = "S"
END_SYM = "E"
BLOCK = "#"

# Load grid into nested array:
with open('../inputs/input20.txt') as fp:
    grid = [[char for char in line_str.strip()] for line_str in fp.readlines()]

ydim = len(grid)
xdim = len(grid[0])

halls = set()
walls = set()

for y in range(ydim):
    for x in range(xdim):
        if grid[y][x] == BLOCK:
            walls.add((y, x))
        else:
            halls.add((y, x))
            if grid[y][x] == START_SYM:
                start_yx = (y, x)
            elif grid[y][x] == END_SYM:
                end_yx = (y, x)


def print_grid():
    display = ""
    for y in range(ydim):
        for x in range(xdim):
            display += grid[y][x]
        display += "\n"
    print(display)


def grid_val(coords):
    (y, x) = coords
    return grid[y][x]


@functools.cache
def manhattan_dist(p1, p2):
    (y1, x1) = p1
    (y2, x2) = p2
    return abs(y2-y1) + abs(x2-x1)


@functools.cache
def neighbours(point):
    (y, x) = point
    up    = (y-1, x)
    down  = (y+1, x)
    left  = (y, x-1)
    right = (y, x+1)
    return [nb for nb in [up, down, left, right] if grid_val(nb) != BLOCK]


# Finds only path from start to goal
def step_through_maze(start, end):
    steps_taken = [start]
    position = start
    while position != end:
        # in this maze there is only one route, so we can rely on [0]
        position = [nb for nb in neighbours(position) if nb not in steps_taken][0]
        steps_taken.append(position)
    return steps_taken


maze_shortest_path = step_through_maze(start_yx, end_yx)
print(len(maze_shortest_path) - 1, "steps") # 9440


# Count all possible cheats of up to max_cheat_dist, which give a saving of at least min_saving
def solve(max_cheat_dist, min_saving):
    cheats = set()
    for i in range(0, len(maze_shortest_path) + 1 - min_saving):
        j = i + min_saving
        ipos = maze_shortest_path[i]
        remaining_maze = maze_shortest_path[j:]
        y, x = ipos
        y0, y1 = max(0, y - max_cheat_dist), min(ydim-1, y + max_cheat_dist)
        x0, x1 = max(0, x - max_cheat_dist), min(xdim-1, x + max_cheat_dist)
        cheatable_square = [(cy,cx) for cy in range(y0, y1+1) for cx in range(x0, x1+1)]
        # following filterings should go from least to most expensive
        cheatable_ahead_halls = [c for c in cheatable_square if c in remaining_maze]
        usable_cheat_exits = [c for c in cheatable_ahead_halls if manhattan_dist(ipos, c) <= max_cheat_dist]

        for uc in usable_cheat_exits:
            k = j + remaining_maze.index(uc)
            saving = k - i - manhattan_dist(ipos, uc)
            if saving > 0:
                cheats.add((ipos, uc, saving))

    return len([c for c in cheats if c[2] >= min_saving])


# Part 1: Based on the shortest path from start to end, find cheats of up to 2 steps
# which can be pass through a single wall, to give a saving of >= 100 moves
print("P1:", solve(2, 100))

# Part 2: Based on the shortest path from start to end, find cheats of up to 20 steps
# which can be pass through any walls, to give a saving of >= 100 moves
print("P2:", solve(20, 100)) # THIS IS SLOW

# P1: 1332
# P2: 987695