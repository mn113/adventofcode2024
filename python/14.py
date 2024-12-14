rows = 103
cols = 101
grid = [[None] * cols for _ in range(rows)]
robots = []


class Robot:
    def __init__(self, initial_coords, velocity):
        self.id = len(robots) + 1
        self.y = initial_coords[1]
        self.x = initial_coords[0]
        self.dy = velocity[1]
        self.dx = velocity[0]

    def move(self):
        self.y += self.dy
        if self.y < 0:
            self.y += rows
        elif self.y >= rows:
            self.y -= rows
        self.x += self.dx
        if self.x < 0:
            self.x += cols
        elif self.x >= cols:
            self.x -= cols

    def __str__(self):
        return "Robot {} now at ({}, {})".format(self.id, self.y, self.x)


# read position and velocity from all input lines
def read_file():
    with open('../inputs/input14.txt') as fp:
        for line in fp.readlines():
            parts = line.strip().split(" ")
            position = [int(s) for s in parts[0][2:].split(",")]
            velocity = [int(s) for s in parts[1][2:].split(",")]
            robots.append(Robot(position, velocity))
read_file();


def print_grid():
    display = ""
    for y in range(rows):
        for x in range(cols):
            cellrobots = [rb for rb in robots if rb.x == x and rb.y == y]
            if len(cellrobots) == 0:
                display += '.'
            else:
                display += str(len(cellrobots))
        display += "\n"
    print(display)


def count_by_region(x0, x1, y0, y1):
    count = 0
    for y in range(y0, y1):
        for x in range(x0, x1):
            count += len([rb for rb in robots if rb.x == x and rb.y == y])
    return count


def count_by_quadrant():
    mid_x = cols // 2
    mid_y = rows // 2
    counts = [0,0,0,0]
    counts[0] = count_by_region(0, mid_x, 0, mid_y)
    counts[1] = count_by_region(mid_x + 1, cols, 0, mid_y)
    counts[2] = count_by_region(0, mid_x, mid_y + 1, rows)
    counts[3] = count_by_region(mid_x + 1, cols, mid_y + 1, rows)
    return counts


t = 0
while t < 7200:
    if t < 100 or t > 7000:
        for r in robots:
            r.move()
        t += 1
    else:
        for r in robots:
            for i in range(10):
                r.move()
        t += 10

    if t % 1000 == 0:
        print("t = ", t)

    # part 1 - find the product of quadrants after 100 seconds
    if t == 100:
        cbq = count_by_quadrant()
        print("P1:", cbq[0] * cbq[1] * cbq[2] * cbq[3])

    # part 2 - find a state representing a Christmas tree
    middle_count = count_by_region(47, 52, 48, 53) # area 5x5 must be fully packed
    if middle_count >= 25:
        print("t = ", t)
        print_grid()
        print("P2:", t)


# P1: 229632480
# P2: 7051
