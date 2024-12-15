#!/usr/bin/env ruby

SPACE = "."
ROBOT = "@"
INPUTWALL = "#" # prints with slash, so replace
WALL = "W"
BOX = "O"
BOXL = "["
BOXR = "]"

DIRS = {
    "<" => [0, -1],
    ">" => [0, 1],
    "^" => [-1, 0],
    "v" => [1, 0]
}

@rpos = [0,0]
@grid = [[]]
@moves = []
@ydim = 0
@xdim = 0

def read_input(width = 1)
    grid = []
    moves_str = ""

    input = File.open("../inputs/input15.txt", "r")
    input.each_line.each_with_index do |line,y|
        if line.start_with? INPUTWALL
            line = line.chomp.chars.map do |char|
                if char == SPACE
                    [SPACE] * width
                elsif char == INPUTWALL
                    [WALL] * width
                elsif char == BOX
                    width == 2 ? [BOXL, BOXR] : BOX
                elsif char == ROBOT
                    width == 2 ? [ROBOT, SPACE] : ROBOT
                end
            end.flatten

            grid.push(line)

            # find robot pos
            rposx = line.index(ROBOT)
            if !rposx.nil?
                @rpos = [y, rposx]
            end
        elsif !line.start_with? "\n"
            moves_str += line.chomp
        end
    end

    [grid, moves_str.chars.map{ |c| DIRS[c] }]
end

def print_grid()
    for y in (0...@ydim) do
        s = ""
        for x in (0...@xdim) do
            s += @grid[y][x]
        end
        p "#{s}"
    end
    printf "\n"
end

def grid_val(coords)
    y, x = coords
    @grid[y][x]
end

def is_box_type?(coords)
    v = grid_val(coords)
    v == BOX || v == BOXL || v == BOXR
end

# move robot (width 1) into a (known-empty) cell
def move_only_robot(cell)
    cy, cx = cell
    ry, rx = @rpos
    @grid[cy][cx] = ROBOT
    @grid[ry][rx] = SPACE
    @rpos = cell
end

def process_move(dir = [1,0])
    next_cell = [@rpos[0] + dir[0], @rpos[1] + dir[1]]
    next_plus_one_cell = next_cell.dup
    if grid_val(next_cell) == SPACE
        # move into available cell
        move_only_robot(next_cell)
        return
    elsif grid_val(next_cell) == BOX
        boxes = []
        # can push multiple boxes
        # continue looking along stretch, until space or wall found
        can_push = true
        while true do
            next_plus_one_cell = [next_plus_one_cell[0] + dir[0], next_plus_one_cell[1] + dir[1]]
            if grid_val(next_plus_one_cell) == SPACE
                boxes.push(next_plus_one_cell)
                break
            elsif grid_val(next_plus_one_cell) == BOX
                boxes.push(next_plus_one_cell)
            elsif grid_val(next_plus_one_cell) == WALL
                can_push = false
                break
            end
        end
        # now move the lot
        if can_push
            boxes.each { |by,bx|
                @grid[by][bx] = BOX
            }
            move_only_robot(next_cell)
        end
    end
end

def process_move_wide(dir = [1,0])
    if dir[0] == 0
        process_horiz_move_wide(dir)
    else
        process_vert_move_wide(dir)
    end
end

def process_horiz_move_wide(dir = [0,1])
    next_cell = [@rpos[0] + dir[0], @rpos[1] + dir[1]]
    next_plus_one_cell = next_cell.dup
    if grid_val(next_cell) == SPACE
        # move into available cell
        move_only_robot(next_cell)
        return
    elsif grid_val(next_plus_one_cell) == BOXL || grid_val(next_plus_one_cell) == BOXR
        boxes = [next_plus_one_cell]
        # can push multiple boxes
        # continue looking along stretch, until space or wall found
        can_push = true
        while true do
            next_plus_one_cell = [next_plus_one_cell[0] + dir[0], next_plus_one_cell[1] + dir[1]]
            if grid_val(next_plus_one_cell) == SPACE
                boxes.push(next_plus_one_cell)
                break
            elsif grid_val(next_plus_one_cell) == BOXL || grid_val(next_plus_one_cell) == BOXR
                boxes.push(next_plus_one_cell)
            elsif grid_val(next_plus_one_cell) == WALL
                can_push = false
                break
            end
        end
        # now move the lot by 1 unit
        if can_push
            boxes.reverse.each_cons(2){ |b1,b2|
                @grid[b1[0]][b1[1]] = @grid[b2[0]][b2[1]]
            }
            move_only_robot(next_cell)
        end
    end
end

def get_next_1_or_2_vert_cells(cell, dir = [1,0])
    next_cell = [cell[0] + dir[0], cell[1]]
    if is_box_type?(next_cell)
        get_box_cells(next_cell)
    else
        [next_cell]
    end
end

def get_box_cells(cell)
    if grid_val(cell) == BOXL
        cell_partner = [cell[0], cell[1] + 1]
        [cell.dup, cell_partner]
    elsif grid_val(cell) == BOXR
        cell_partner = [cell[0], cell[1] - 1]
        [cell_partner, cell.dup]
    else
        raise StopIteration "oops!"
    end
end

def process_vert_move_wide(dir = [1,0])
    next_cell = [@rpos[0] + dir[0], @rpos[1]]
    if grid_val(next_cell) == SPACE
        # move into available cell
        move_only_robot(next_cell)
        return

    elsif is_box_type?(next_cell)
        next_cells = get_box_cells(next_cell)
        old_boxes = [next_cells]
        new_boxes_rows = []
        # can push multiple boxes
        # continue looking at all concerned boxes in a row, until 1 wall, or all spaces, are found
        can_push = true
        while true do
            cells_to_check = new_boxes_rows.length > 0 ? new_boxes_rows.last : next_cells
            next_cells_to_check = cells_to_check
                .reject{ |c| grid_val(c) == SPACE }
                .flat_map{ |cell| get_next_1_or_2_vert_cells(cell, dir) }
                .uniq
            old_boxes.push(next_cells_to_check.filter{ |cell| is_box_type?(cell) })

            if next_cells_to_check.map{ |c| grid_val(c) }.all?{ |v| v == SPACE }
                new_boxes_rows.push(next_cells_to_check)
                break
            elsif next_cells_to_check.map{ |c| grid_val(c) }.any?{ |v| v == WALL }
                can_push = false
                break
            else # row must be a mix of boxes and spaces
                new_boxes_rows.push(next_cells_to_check)
            end
        end
        # now move the lot
        if can_push
            old_boxes.flatten!(1)
            tmpgrid = @grid.dup.map{ |row| row.dup }
            old_boxes.each { |box|
                by, bx = box
                # erase old boxes from tmpgrid
                tmpgrid[by][bx] = SPACE
            }
            old_boxes.each { |box|
                if is_box_type?(box)
                    by, bx = box
                    ahead_y = by + dir[0]
                    ahead_box = [ahead_y, bx]
                    # write the new boxes into tmpgrid
                    tmpgrid[ahead_y][bx] = grid_val(box)
                end
            }
            @grid = tmpgrid
            move_only_robot(next_cell)
        end
    end
end


def count_boxes(grid)
    boxl, boxr = grid.reduce([0,0]){ |acc, row| [acc[0] + row.count(BOXL), acc[1] + row.count(BOXR)] }
    "#{boxl} BOXL, #{boxr} BOXR"
end

def count_boxes_score(grid)
    score = 0
    for y in (0...@ydim) do
        for x in (0...@xdim) do
            if grid[y][x] == BOX || grid[y][x] == BOXL
                score += 100 * y + x
            end
        end
    end
    score
end

# Cell width = 1. Process all robot moves. Sum box positions.
def part1()
    width = 1
    @grid, @moves = read_input(width)
    @ydim = @grid.size
    @xdim = @grid[0].size
    @moves.each{ |m|
        process_move(m)
    }
    print_grid()
    p "Part 1: #{count_boxes_score(@grid)}"
end
part1()

# Cell width = 2. Process all robot moves. Sum box positions.
def part2()
    width = 2
    @grid, @moves = read_input(width)
    @ydim = @grid.size
    @xdim = @grid[0].size
    @moves.each{ |m|
        process_move_wide(m)
    }
    print_grid()
    p "Part 2: #{count_boxes_score(@grid)}"
end
part2()

# P1: 1412971
# P2: 1429299
