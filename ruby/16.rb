require 'set'

# ingest map to 2D array
@maze = File.open("../inputs/input16.txt", "r").each_line.map(&:strip).map(&:chars)

STEP_COST = 1
TURN_COST = 1000

WALL = "#"
DEADEND = "/"
START_SYM = "S"
END_SYM = "E"

DIRS = {
    :N => [-1, 0],
    :E => [0, 1],
    :S => [1, 0],
    :W => [0, -1],
}
DIRS_FLIP = {
    [-1, 0] => :N,
    [0, 1] => :E,
    [1, 0] => :S,
    [0, -1] => :W,
}

sy = @maze.find_index{|row| row.include?(START_SYM)}
sx = @maze[sy].find_index(START_SYM)
@start = [sy, sx]

ey = @maze.find_index{|row| row.include?(END_SYM)}
ex = @maze[ey].find_index(END_SYM)
@end = [ey, ex]

def isHall(node)
    y, x = node
    @maze[y][x] != WALL && @maze[y][x] != DEADEND
end

def neighbours(node)
    y, x = node[:pt]
    dir = DIRS[node[:hd]]
    [DIRS[:N], DIRS[:E], DIRS[:S], DIRS[:W]]
        .sort{ |a,b| a == dir ? 1 : -1 } # put cheapest dir ahead in return val
        .map{ |dy,dx| [y+dy, x+dx] }
        .select{ |ny,nx| isHall([ny, nx]) }
end

def get_turns(heading, coords, neighb)
    dy = neighb[0] - coords[0]
    dx = neighb[1] - coords[1]
    cost = if DIRS[heading] == [dy, dx] then 0
        elsif  DIRS[heading] == [-dy, -dx] then 2
        else 1 end
    newHeading = DIRS_FLIP[[dy, dx]]
    [cost, newHeading]
end

# Main algo:
def bfs(start, goal)
    start_node = { pt: start, hd: :E }
    to_visit = [start_node]
    visited = Set.new()
    cost_to = Hash.new(0)    # measures travel cost to each node
    came_from = { start => nil }   # traces the path taken
    lowest_cost_to_goal = 1_000_000

    while to_visit.length > 0 do
        # heuristic - prioritise visiting cheaper nodes
        to_visit.sort!{ |a,b| cost_to[a[:pt]] - cost_to[b[:pt]] }

        current = to_visit.shift()
        visited.add(current)
        y, x = current[:pt]

        if current[:pt] == goal
            p "GOAL! cost #{cost_to[goal]}"
            if cost_to[goal] < lowest_cost_to_goal
                lowest_cost_to_goal = cost_to[goal]
            end
        end

        neighbs = neighbours(current)

        neighbs.map{ |nb| { pt: nb } }.each do |next_node|
            # is turning necessary to have reached that node?
            turns, next_heading = get_turns(current[:hd], current[:pt], next_node[:pt])
            next if turns > 1 # overturning = bad move, reject
            next_node[:hd] = next_heading

            # Next node will cost 0/1 turns and 1 more step than current node did:
            new_cost = cost_to[current[:pt]] + (TURN_COST * turns) + STEP_COST
            # reject if path too costly
            next if new_cost > lowest_cost_to_goal

            if !(visited.to_a.any?{ |node| node[:pt] == next_node[:pt] })
                # Add to queue:
                to_visit.push(next_node)
                cost_to[next_node[:pt]] = new_cost
                came_from[next_node[:pt]] = current[:pt]
            else
                if new_cost < cost_to[next_node[:pt]]
                    # Via current, we have found a new, shorter path to this known next_node:
                    cost_to[next_node[:pt]] = new_cost
                    came_from[next_node[:pt]] = current[:pt]
                end
            end
        end
    end

    printf "\n"

    # Finished seeing nodes now
    if came_from.keys.any?{ |node| node == goal }
        traceback(goal, came_from)
        lowest_cost_to_goal
    else
        "No path found"
    end
end

def traceback(goal, came_from)
    # p "Traceback from goal #{goal}"
    parent = came_from[goal]
    until parent.nil? do
        @maze[parent[0]][parent[1]] = '0'
        parent = came_from[parent]
    end
end

lowest_cost = bfs(@start, @end)
printf @maze.map(&:join).join("\n") + "\n"
p "P1: #{lowest_cost}"

# P1: 107468