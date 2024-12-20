use std::fs::read_to_string;

// https://doc.rust-lang.org/stable/rust-by-example/std_misc/file/read_lines.html
fn read_lines(filename: &str) -> Vec<Vec<i32>> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(|line| {
            line.split_whitespace()
                .map(|numstr| numstr.parse::<i32>().unwrap())
                .collect::<Vec<i32>>()
        })
        .collect()
}

fn is_increasing(line: &Vec<i32>) -> bool {
    if line.len() >= 2 {
        let diff = line[0] - line[1];
        diff >= -3 && diff <= -1 && is_increasing(&line[1..].to_vec())
    } else {
        true
    }
}

fn is_decreasing(line: &Vec<i32>) -> bool {
    if line.len() >= 2 {
        let diff = line[0] - line[1];
        diff >= 1 && diff <= 3 && is_decreasing(&line[1..].to_vec())
    } else {
        true
    }
}

// Check if line is uniformly increasing or decreasing by steps of 1-3
fn is_safe(line: &Vec<i32>) -> bool {
    is_increasing(line) || is_decreasing(line)
}

// Get all line variants with a single step removed
fn get_variants(line: &Vec<i32>) -> Vec<Vec<i32>> {
    let n = line.len();
    (0..n)
        .map(|i| {
            let mut new_line = line.clone();
            new_line.remove(i);
            new_line
        })
        .collect()
}

// Count the lines which are safe
fn part1(lines: Vec<Vec<i32>>) -> usize {
    lines
        .into_iter()
        .filter(|line| is_safe(line))
        .collect::<Vec<_>>()
        .len()
}

// Count the lines which are safe if any one step can be removed
fn part2(lines: Vec<Vec<i32>>) -> usize {
    lines
        .into_iter()
        .map(|line| get_variants(&line))
        .filter(|variants| variants.iter().any(|variant| is_safe(variant)))
        .collect::<Vec<_>>()
        .len()
}

fn main() {
    let lines = read_lines("../../inputs/input02.txt");
    println!("P1: {}", part1(lines.clone()));
    println!("P2: {}", part2(lines.clone()));
}

// P1: 279
// P2: 343
