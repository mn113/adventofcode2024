use std::fs::read_to_string;
use regex::Regex;
use num_complex::Complex;

const A_PRESS_COST: u64 = 3;
const B_PRESS_COST: u64 = 1;
const STUPID_FACTOR: u64 = 10_000_000_000_000;

#[derive(Clone, Debug)]
struct Game {
    a: Complex<u64>,
    b: Complex<u64>,
    prize: Complex<u64>
}

impl Game {
    fn new() -> Game {
        Game {
            a: Complex::new(0,0),
            b: Complex::new(0,0),
            prize: Complex::new(0,0)
        }
    }
}


// https://doc.rust-lang.org/stable/rust-by-example/std_misc/file/read_lines.html
fn read_lines(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}


fn parse_games(lines: Vec<String>) -> Vec<Game> {
    let mut games: Vec<Game> = vec![];
    let mut game = Game::new();

    lines.iter().for_each(|line| {
        if line.len() > 0 {
            let re = Regex::new(r"X[+=]?(?<x>\d+), Y[+=]?(?<y>\d+)").unwrap();
            let caps = re.captures(line).unwrap();
            let x = caps.name("x").unwrap().as_str().parse::<u64>().unwrap();
            let y = caps.name("y").unwrap().as_str().parse::<u64>().unwrap();
            // println!("X: {}, Y: {}", x, y);

            if line.starts_with("Button A") {
                game.a = Complex::new(x, y);
            }
            else if line.starts_with("Button B") {
                game.b = Complex::new(x, y);
            }
            else if line.starts_with("Prize") {
                game.prize = Complex::new(x, y);
            }
        }
        else {
            games.push(game.clone());
            // println!("{:?}", game);
            // println!("{:?}", games);
            game = Game::new();
        }
    });

    return games
}


// find the cost (in weighted presses) of solving one game
// eq1: game.a.re * a_presses + game.b.re * b_presses = prize.re
// eq2: game.a.im * a_presses + game.b.im * b_presses = prize.im
fn solve_matrix(game: Game, stupid_factor: u64, presses_limit: u64) -> u64 {
    let mut prize = game.prize;
    prize += Complex::new(stupid_factor, stupid_factor);

    let det_d: i64 = (game.a.re * game.b.im) as i64 - (game.a.im * game.b.re) as i64;
    let det_a: i64 = (prize.re * game.b.im) as i64 - (game.b.re * prize.im) as i64;
    let det_b: i64 = (game.a.re * prize.im) as i64 - (prize.re * game.a.im) as i64;

    let a_presses_f32: f64 = det_a as f64 / det_d as f64;
    let b_presses_f32: f64 = det_b as f64 / det_d as f64;

    let a_presses: u64 = a_presses_f32.floor() as u64;
    let b_presses: u64 = b_presses_f32.floor() as u64;

    if (a_presses_f32 == a_presses_f32.floor()) && (b_presses_f32 == b_presses_f32.floor() &&
        a_presses <= presses_limit && b_presses <= presses_limit) {
        // println!("{} A presses and {} B presses wins", a_presses, b_presses);
        return a_presses * A_PRESS_COST + b_presses * B_PRESS_COST
    }
    return 0
}


fn main() {
    let games = parse_games(read_lines("../../inputs/input13.txt"));
    println!("{} games parsed", games.len());
    println!("P1: {}", games.clone().into_iter().map(|g| solve_matrix(g.clone(), 0, 100)).sum::<u64>());
    println!("P2: {}", games.clone().into_iter().map(|g| solve_matrix(g.clone(), STUPID_FACTOR, STUPID_FACTOR)).sum::<u64>());
}

// P1: 35082
// P2: 82570698600470