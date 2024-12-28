use std::fs::read_to_string;

fn read_lines(filename: &str) -> (Vec<Vec<u32>>, Vec<Vec<u32>>) {
    let mut rules = Vec::new();
    let mut page_lists = Vec::new();

    read_to_string(filename)
        .unwrap()
        .lines()
        .for_each(|line| {
            let line_str = line.trim();

            if line_str.find('|').is_some() {
                let parts = line_str.split('|').map(|part| part.parse::<u32>().unwrap()).collect::<Vec<u32>>();
                rules.push(parts)
            }
            else if line_str.find(',').is_some() {
                let parts = line_str.split(',').map(|part| part.parse::<u32>().unwrap()).collect::<Vec<u32>>();
                page_lists.push(parts)
            }
        });

    (rules, page_lists)
}

// Check if a single rule is passed by its members positions in a page list
fn is_rule_passed(rule: Vec<u32>, page_list: Vec<u32>) -> bool {
    if !page_list.contains(&rule[0]) || !page_list.contains(&rule[1]) {
        return true
    }
    let index_a = page_list.iter().position(|r| r == &rule[0]); // can be None or Some(isize)
    let index_b = page_list.iter().position(|r| r == &rule[1]);
    index_a < index_b
}

// Check if all rules are passed
fn is_all_rules_passed(rules: Vec<Vec<u32>>, page_list: Vec<u32>) -> bool {
    rules.iter().all(|rule| is_rule_passed(rule.to_vec(), page_list.clone()))
}

// Get the element in the middle of a list
fn middle_of_list(page_list: Vec<u32>) -> u32 {
    let len = page_list.len() as f32;
    let mid = (len / 2.0).floor() as usize;
    page_list[mid]
}

// Find the probable middle element, based on finding the element with an equal number of siblings before and after
fn find_middle(rules: Vec<Vec<u32>>, page_list: Vec<u32>) -> u32 {
    let mut middle: u32 = 0;
    page_list
    .iter()
    .any(|n| {
        let mut must_come_before = 0;
        let mut must_come_after = 0;
        rules.iter().for_each(|rule| {
            if &rule[1] == n && page_list.contains(&rule[0]) {
                must_come_before += 1
            }
            if &rule[0] == n && page_list.contains(&rule[1]) {
                must_come_after += 1
            }
        });
        if must_come_before == must_come_after {
            middle = *n;
            true
        }
        else {
            false
        }
    });
    middle
}


// Part 1
// Sum the middle elements of all valid page lists
fn part1(rules: Vec<Vec<u32>>, page_lists: Vec<Vec<u32>>) -> u32 {
    let valid_page_lists = page_lists.iter().filter(|page_list| is_all_rules_passed(rules.clone(), page_list.to_vec()));
    let middle_pages = valid_page_lists.map(|page_list| middle_of_list(page_list.to_vec()));
    middle_pages.sum()
}

// Part 2
// Sum the middle elements of all invalid page lists
fn part2(rules: Vec<Vec<u32>>, page_lists: Vec<Vec<u32>>) -> u32 {
    let invalid_page_lists = page_lists.iter().filter(|page_list| !is_all_rules_passed(rules.clone(), page_list.to_vec()));
    let middle_pages = invalid_page_lists.map(|page_list| find_middle(rules.clone(), page_list.to_vec()));
    middle_pages.sum()
}

fn main() {
    let (rules, page_lists) = read_lines("../../inputs/input05.txt");
    println!("P1: {}", part1(rules.clone(), page_lists.clone()));
    println!("P2: {}", part2(rules.clone(), page_lists.clone()));
}

// P1: 4957
// P2: 6938
