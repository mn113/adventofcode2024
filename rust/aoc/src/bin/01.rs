use std::fs::read_to_string;

// https://doc.rust-lang.org/stable/rust-by-example/std_misc/file/read_lines.html
fn read_lines(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}

// Transform N rows of 2 values to 2 columns of N values each
fn to_columns(lines: Vec<String>) -> (Vec<u32>, Vec<u32>) {
    lines
        .into_iter()
        .map(|line| {
            let pair = line.split_whitespace()
                .map(|part| part.parse::<u32>().unwrap())
                .collect::<Vec<u32>>();
            // return tuple:
            (
                pair.get(0).expect("Error").to_owned(),
                pair.get(1).expect("Error").to_owned()
            )
        })
        .collect::<(Vec<u32>, Vec<u32>)>()
}

// Sort 2 lists ascending, find diff between each number pair, sum them.
fn part1(col1: Vec<u32>, col2: Vec<u32>) -> i32 {
    let mut sorted_col1 = col1;
    let mut sorted_col2 = col2;
    sorted_col1.sort_unstable();
    sorted_col2.sort_unstable();

    sorted_col1
        .into_iter()
        .zip(sorted_col2.into_iter())
        .map(|(a, b)| (b as i32 - a as i32).abs())
        .sum()
}

// Find similarity: sum of count of col2 appearances of each col1 value
fn part2(col1: Vec<u32>, col2: Vec<u32>) -> i32 {
    col1.iter()
        .map(|a| *a as i32 * col2.iter().filter(|b| b == &a).count() as i32)
        .sum()
}

fn main() {
    let (col1, col2) = to_columns(read_lines("../../inputs/input01.txt"));
    println!("P1: {}", part1(col1.clone(), col2.clone()));
    println!("P2: {}", part2(col1.clone(), col2.clone()));
}

// P1: 2769675
// P2: 24643097
