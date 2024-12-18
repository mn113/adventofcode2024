#! /usr/bin/env python3

BLOCK = "#"

ydim = 71
xdim = 71
limit = 1024
block_stream = []
grid = [['.'] * xdim for _ in range(ydim)]

def read_file():
    with open('../inputs/input18.txt') as fp:
        i = 0
        for line in fp.readlines():
            x, y = [int(s) for s in line.strip().split(",")]
            block_stream.append((x,y))
            # for part 1, only blocks up to the defined limit go into the grid
            if i < limit:
                grid[y][x] = BLOCK
            i += 1
read_file()


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


def neighbours(point):
    (y, x) = point
    up    = (max(y-1, 0), x)
    down  = (min(y+1, ydim-1), x)
    left  = (y, max(x-1, 0))
    right = (y, min(x+1, xdim-1))
    # nb must not be point (edge/corner cases)
    return [nb for nb in [up, down, left, right] if not (nb[0] == y and nb[1] == x) and grid_val(nb) != BLOCK]


# Main algo: Dijkstra / BFS
# Finds lowest cost path from start to goal. Visits all points in grid, storing and updating cost to reach each one.
def dijkstra(start, goal):
    steps_to = {start: 0} # measures cumulative cost from start to each node; keys function as "seen" list
    to_visit = [start]          # list-as-queue
    came_from = {start: None}   # traces the optimal path taken

    while len(to_visit) > 0:
        # Shift first
        currentNode, to_visit = to_visit[0], to_visit[1:]

        if currentNode == goal and steps_to[currentNode] > 0:
            print('GOAL!', len(to_visit), "to see")
            # Keep searching, to guarantee shortest:
            continue

        neighbs = neighbours(currentNode)

        for nextNode in neighbs:
            # nextNode unseen:
            if nextNode not in steps_to.keys():
                to_visit.append(nextNode)
                # Next node will cost 1 more than this node did:
                steps_to[nextNode] = steps_to[currentNode] + 1
                came_from[nextNode] = currentNode
            # nextNode seen before:
            else:
                if steps_to[nextNode] > steps_to[currentNode] + 1:
                    # Via currentNode, we have found a new, shorter path to nextNode:
                    steps_to[nextNode] = steps_to[currentNode] + 1
                    came_from[nextNode] = currentNode
                    to_visit.append(nextNode)

                elif steps_to[currentNode] > steps_to[nextNode] + 1:
                    # Via nextNode, we have found a new, shorter path to currentNode:
                    steps_to[currentNode] = steps_to[nextNode] + 1
                    came_from[currentNode] = nextNode
                    to_visit.append(currentNode)

    if goal in came_from.keys():
        print("P1:", steps_to[goal], "steps to goal")


# Part 1: Find shortest path from (0,0) to opposite corner, avoiding blocks
start_yx = (0,0)
goal_yx = (ydim-1, xdim-1)
dijkstra(start_yx, goal_yx)

# Part 2: Find the first block (x,y) which will fully block the path
# By playing with limit:
# 1024: solvable
# 2048: solvable
# 3450: not solvable
# 2500: solvable
# 3000: not solvable
# 2750: solvable
# 2875: solvable
# 2940: solvable
# 2970: solvable
# 2985: solvable
# 2992: not solvable
# 2988: not solvable
# 2987: not solvable
# 2986: solvable
print("P2:", block_stream[2986])

# P1: 324
# P2: 46,23
