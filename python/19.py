#! /usr/bin/env python3

def read_file():
    with open('../inputs/input19.txt') as fp:
        lines = fp.readlines()
        pieces = lines[0].strip().split(", ")
        targets = [line.strip() for line in lines[2:]]
    return [pieces, targets]

pieces, targets = read_file()

# Look for any way of solving a target string
# A target is solvable if it can be composed of the input pieces
def validate_target(target):
    to_check = [target]
    while to_check:
        current = to_check.pop()
        for piece in pieces:
            if current.startswith(piece):
                newtarget = current.replace(piece, "", 1)
                if newtarget == "":
                    return True
                else:
                    to_check.append(newtarget)
    return False

valid = [target for target in targets if validate_target(target)]
print("P1:", len(valid))


target_solutions_memo = {
    "": 1
}

# Count all possible ways of solving a target string (recursive)
# A target is solvable if it can be composed of the input pieces
def enumerate_target_solutions(target):
    global target_solutions_memo

    if target in target_solutions_memo:
        return target_solutions_memo[target]

    solutions = 0
    for piece in pieces:
        if target.startswith(piece):
            new_target = target.replace(piece, "", 1)
            solutions += enumerate_target_solutions(new_target)

    target_solutions_memo[target] = solutions
    return solutions

solutions = [enumerate_target_solutions(target) for target in targets]
print("P2:", sum(solutions))


# P1: 358
# P2: 600639829400603