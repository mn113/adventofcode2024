use std::fs::read_to_string;
use std::collections::HashMap;
use std::collections::HashSet;

const SPACE: char = '.';

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


fn fill_nodes_by_char(grid: Vec<Vec<char>>) -> HashMap<char, Vec<(i32, i32)>> {
    let ydim = grid.len();
    let xdim = grid[0].len();

    let mut nodes_by_char: HashMap<char, Vec<(i32, i32)>> = HashMap::new();

    // find all the char nodes and group them by char
    for y in 0..ydim {
        for x in 0..xdim {
            let coord = (y as i32, x as i32);
            let c = grid[y][x];

            if c != SPACE {
                nodes_by_char.entry(c)
                    .and_modify(|list| list.push(coord))
                    .or_insert(vec![coord]);
            }
        }
    }

    return nodes_by_char
}


// find the amount of antinodes in the grid
#[allow(unused_assignments)]
fn solve(grid: Vec<Vec<char>>, nodes_by_char: HashMap<char, Vec<(i32, i32)>>, min_antinode_reach: i32, max_antinode_reach: i32) -> i32 {
    let ydim = grid.len() as i32;
    let xdim = grid[0].len() as i32;

    let mut all_antinodes = HashSet::new();

    for (_c, nodes) in &nodes_by_char {
        // consider all combinations of 2 different nodes
        for n1 in nodes {
            for n2 in nodes {
                if n1 == n2 {
                    continue
                }
                let (y1, x1) = n1;
                let (y2, x2) = n2;
                let delta = (y2 - y1, x2 - x1);
                // reach ahead to find each harmonic antinode
                let mut reach = min_antinode_reach;
                while reach < max_antinode_reach {
                    let y3 = y2 + (delta.0 * reach);
                    let x3 = x2 + (delta.1 * reach);
                    if y3 < 0 || y3 >= ydim || x3 < 0 || x3 >= xdim {
                        // force search to stop in this direction
                        reach = max_antinode_reach;
                        break
                    }
                    all_antinodes.insert((y3, x3));
                    reach += 1
                }
            }
        }
    }

    return all_antinodes.len() as i32
}


fn main() {
    let grid = prep_grid(read_lines("../../inputs/input08.txt"));
    let nodes_by_char = fill_nodes_by_char(grid.clone());
    println!("P1: {}", solve(grid.clone(), nodes_by_char.clone(), 1, 2));
    println!("P2: {}", solve(grid.clone(), nodes_by_char.clone(), 0, 50));
}

// P1: 214
// P2: 809