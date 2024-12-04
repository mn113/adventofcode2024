use std::fs::read_to_string;

// https://doc.rust-lang.org/stable/rust-by-example/std_misc/file/read_lines.html
fn read_lines(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}

fn prep_grid(lines: Vec<String>) -> Vec<Vec<char>> {
    lines
    .iter()
    .map(|line| {
        line.chars().collect::<Vec<char>>()
    })
    .collect::<Vec<Vec<char>>>()
}

// Part 1
// search for the word 'XMAS' in 8 directions
fn part1(grid: Vec<Vec<char>>) -> i32 {
    let ydim = grid.len();
    let xdim = grid[0].len();

    let mut found_xmases = 0;

    // unsigned y, x, ydim, xdim
    for y in 0..ydim {
        for x in 0..xdim {
            if grid[y][x] == 'X' {
                // check 8 neighours of 'X'
                let trio: Vec<i32> = vec![-1, 0, 1];
                for dy in &trio {
                    for dx in &trio {
                        let x1: i32 = x as i32 + dx;
                        let y1: i32 = y as i32 + dy;
                        let x2: i32 = x1 + dx;
                        let y2: i32 = y1 + dy;
                        let x3: i32 = x2 + dx;
                        let y3: i32 = y2 + dy;

                        // skip deltas that stay in one spot or go out of bounds
                        if *dx == 0 && *dy == 0 {
                            continue
                        }
                        // unsigned xdim ydim
                        if x3 < 0 || x3 as usize >= xdim || y3 < 0 || y3 as usize >= ydim {
                            continue
                        }
                        // check next 3 letters
                        if grid[y1 as usize][x1 as usize] == 'M' {
                            if grid[y2 as usize][x2 as usize] == 'A' {
                                if grid[y3 as usize][x3 as usize] == 'S' {
                                    found_xmases += 1
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    found_xmases
}

// Part 2
// search for the word 'MAS' crossing another 'MAS' in an X-shape
fn part2(grid: Vec<Vec<char>>) -> i32 {
    let ydim = grid.len();
    let xdim = grid[0].len();

    let mut found_mas_mas = 0;

    // unsigned y, x, ydim, xdim
    for y in 1..ydim-1 {
        for x in 1..xdim-1 {
            if grid[y][x] == 'A' {
                // check for MAS occurring on 2 diagonals
                let corners = [(x+1, y+1), (x+1, y-1), (x-1, y-1), (x-1, y+1)];
                let mut corner_letters = corners.map(|c| grid[c.1][c.0]);
                let corner_letters_str = corner_letters.iter().collect::<String>();

                // ignore MAM & SAS:
                if corner_letters_str == "MSMS" || corner_letters_str == "SMSM" {
                    continue
                }

                corner_letters.sort();
                if ['M', 'M', 'S', 'S'] == corner_letters {
                    found_mas_mas += 1
                }
            }
        }
    }
    found_mas_mas
}

fn main() {
    let grid = prep_grid(read_lines("../inputs/input04.txt"));
    println!("P1: {}", part1(grid.clone()));
    println!("P2: {}", part2(grid.clone()));
}

// P1: 2644
// P2: 1952
