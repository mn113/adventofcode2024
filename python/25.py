#! /usr/bin/env python3

def inline(block):
    return block.replace("\n", "")

# Load input:
with open('../inputs/input25.txt') as fp:
    blocks = [inline(b) for b in fp.read().split("\n\n")]
    locks = [b for b in blocks if b.startswith("#####")]
    keys = [b for b in blocks if b.startswith(".....")]

def match(lock, key):
    for i in range(len(lock)):
        if lock[i] == "#" and key[i] == "#":
            return False
    return True

match_count = 0
for lock in locks:
    for key in keys:
        if match(lock, key):
            match_count += 1


# Part 1: count keys which fit in locks
print("P1:", match_count)

# P1: 2691