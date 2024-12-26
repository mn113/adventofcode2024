<?php

const COUNT = 1;
const NOCOUNT = 0;
const TURNON = 1;
const TURNOFF = -1;

# Read input as lines; concatenate to a single line
function read_input()
{
    $data = file('../inputs/input03.txt'); // array of line strings
    $str = implode("___newline___", $data);
    return $str;
}

# Parse all the valid "mul(\d,\d)" substrings out of the line
function re_parse($line)
{
    $re = "/(do\(\))|(don't\(\))|(mul\((\d{1,3}),(\d{1,3})\))/";
    preg_match_all($re, $line, $matches, PREG_SET_ORDER);

    $mapped = [];
    foreach ($matches as $match) {
        if (substr($match[0], 0, 3) == "mul") {
            $mapped[] = [COUNT, (int) $match[4], (int) $match[5]];
        }
        else if ($match[0] == "don't()") {
            $mapped[] = [NOCOUNT, TURNOFF, NOCOUNT];
        }
        else if ($match[0] == "do()") {
            $mapped[] = [NOCOUNT, TURNON, NOCOUNT];
        }
    }
    return $mapped;
}

# Sum the sums of products of the lines after parsing out the "mul(\d,\d)" substrings
function part1() {
    $mapped_matches = re_parse(read_input());
    $products = array_map(function ($match) {
        return array_reduce($match, function ($acc, $x) {
            return $acc * $x;
        }, 1);
    }, $mapped_matches);

    return array_reduce($products, function ($acc, $p) {
        return $acc + $p;
    }, 0);
}

# Sum the sums of products of the lines taking into account the "mul(\d,\d)", "do()", and "don't()" substrings
function part2() {
    $tracker = ["value" => 0, "counting" => true];

    $mapped_matches = re_parse(read_input());

    $tracker = array_reduce($mapped_matches, function ($acc, $arr) {
        if ($arr[0] == NOCOUNT && $arr[1] == TURNOFF) {
            $acc["counting"] = false;
        }
        else if ($arr[0] == NOCOUNT && $arr[1] == TURNON) {
            $acc["counting"] = true;
        }
        else if ($arr[0] == COUNT && $acc["counting"]) {
            $acc["value"] += $arr[1] * $arr[2];
        }
        return $acc;
    }, $tracker);

    return $tracker["value"];
}

$p1 = part1();
print "P1: $p1\n"; # 174103751
$p2 = part2();
print "P2: $p2\n"; # 100411201
