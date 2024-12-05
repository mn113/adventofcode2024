#! /usr/bin/env python3

rules = []
page_lists = []

with open('../inputs/input05.txt') as fp:
    for line_str in fp.readlines():
        line = line_str.strip()
        if '|' in line:
            parts = [int(part) for part in line.split('|')]
            rules.append(parts)
        elif ',' in line:
            page_lists.append([int(part) for part in line.split(',')])


# Check if a single rule is passed by its members positions in a page list
def is_rule_passed(rule, page_list):
    if rule[0] not in page_list or rule[1] not in page_list:
        return True
    index_a = page_list.index(rule[0])
    index_b = page_list.index(rule[1])
    return index_a < index_b


# Check if all rules are passed
def is_all_rules_passed(page_list):
    return all([is_rule_passed(rule, page_list) for rule in rules])


# Get the element in the middle of a list
def middle_of_list(page_list):
    return page_list[len(page_list) // 2]


##
# Part 1
# Sum the middle elements of all valid page lists
#
valid_page_lists = [page_list for page_list in page_lists if is_all_rules_passed(page_list)]
middle_pages = [middle_of_list(page_list) for page_list in valid_page_lists]
print("Part 1:", sum(middle_pages))


# find the probable middle element, based on finding the element with an equal number of siblings before and after
def find_middle(page_list):
    for n in page_list:
        must_come_before = [rule[0] for rule in rules if rule[1] == n and rule[0] in page_list]
        must_come_after = [rule[1] for rule in rules if rule[0] == n and rule[1] in page_list]
        if len(must_come_before) == len(must_come_after):
            return n
    return None


##
# Part 2
# Sum the middle elements of all invalid page lists
#
invalid_page_lists = [page_list for page_list in page_lists if not is_all_rules_passed(page_list)]
middle_pages = [find_middle(page_list) for page_list in invalid_page_lists]
print("Part 2:", sum(middle_pages))


# P1: 4957
# P2: 6938