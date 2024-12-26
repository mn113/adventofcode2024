<?php
declare(strict_types = 1);

$zeros = [];
$nines = [];
$grid = [];
$dimY = 0;
$dimX = 0;

# Build grid from input
function read_input(): void
{
    global $zeros, $nines, $grid, $dimY, $dimX;

    $data = file('../inputs/input10.txt'); // array of line strings

    foreach ($data as $y => $line) {
        $lineChars = str_split(trim($line));
        foreach ($lineChars as $x => $char) {
            if ($char === '0') {
                $zeros[] = [$y, $x];
            }
            else if ($char === '9') {
                $nines[] = [$y, $x];
            }
        }
        $grid[] = array_map('intval', $lineChars);
    }
    $dimY = count($grid);
    $dimX = count($grid[0]);
}


class State
{
    public $y;
    public $x;
    public $history;

    function __construct($y, $x, $history)
    {
        global $grid;
        $this->y = $y;
        $this->x = $x;
        $this->history = $history || "[$y][$x]={$grid[$y][$x]}";
    }

    public function update($y, $x)
    {
        global $grid;
        $this->y = $y;
        $this->x = $x;
        $this->history .= "[$y][$x]={$grid[$y][$x]}; ";
    }

    public function clone()
    {
        return new State($this->y, $this->x, $this->history);
    }
}


function neighbours($y, $x): array
{
    return array_filter([
        [$y-1, $x], [$y+1, $x], [$y, $x-1], [$y, $x+1]
    ], function ($n) use ($y, $x) {
        global $dimY, $dimX;
        return $n[0] >= 0 && $n[0] < $dimY && $n[1] >= 0 && $n[1] < $dimX;
    });
}

function exists_path_between($start, $end): bool
{
    global $grid;

    [$y0, $x0] = $start;
    [$y1, $x1] = $end;
    // DFS
    $unseen = [[$y0, $x0, $grid[$y0][$x0]]];
    while (count($unseen) > 0) {
        [$cy, $cx, $cval] = array_shift($unseen);
        if ($cy === $y1 && $cx === $x1) {
            return true;
        }
        $nbs = array_filter(neighbours($cy, $cx), function ($nb) use ($cval) {
            global $grid;
            return $grid[$nb[0]][$nb[1]] === $cval + 1;
        });
        $nbs = array_map(function ($nb) {
            global $grid;
            return [$nb[0], $nb[1], $grid[$nb[0]][$nb[1]]];
        }, $nbs);
        $unseen = array_merge($unseen, $nbs);
    }
    return false;
}

function count_paths_between($start, $end): int
{
    [$y0, $x0] = $start;
    [$y1, $x1] = $end;
    $paths = [];
    // DFS
    $unseen = [new State($y0, $x0, false)];
    while (count($unseen) > 0) {
        $current_state = array_shift($unseen);
        if ($current_state->y === $y1 && $current_state->x === $x1) {
            $paths[] = $current_state;
        }
        $nbs = array_filter(neighbours($current_state->y, $current_state->x), function ($nb) use ($current_state) {
            global $grid;
            return $grid[$nb[0]][$nb[1]] === $grid[$current_state->y][$current_state->x] + 1;
        });
        foreach ($nbs as $nb) {
            $state = $current_state->clone();
            $state->update($nb[0], $nb[1]);
            $unseen[] = $state;
        }
    }
    return count($paths);
}

function get_trailhead_simple_score($start): int
{
    global $nines;
    return count(array_filter($nines, function ($end) use ($start) {
        return exists_path_between($start, $end);
    }));
}

function get_trailhead_multi_score(array $start): int
{
    global $nines;
    return array_sum(array_map(function ($end) use ($start) {
        return count_paths_between($start, $end);
    }, $nines));
}

function part1(): int
{
    global $zeros;
    return array_sum(array_map('get_trailhead_simple_score', $zeros));
}

function part2(): int
{
    global $zeros;
    return array_sum(array_map('get_trailhead_multi_score', $zeros));
}

read_input();

// part1 - sum the scores of each trailhead (0) which is how many peaks (9) we can walk to from it
$p1 = part1();
print "P1: $p1\n"; # 733

// part2 - sum the scores of each trailhead (0) which is how many distinct walks to any peak (9) we can do from it
$p2 = part2();
print "P2: $p2\n"; # 1514
