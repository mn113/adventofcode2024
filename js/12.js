const fs = require('fs');

const p = console.log;

const chars = new Set();
const unpainted = {};
const painted = {};

const grid = fs.readFileSync('../inputs/input12.txt', 'utf-8')
    .split('\n')
    .map((line, y) => {
        return line.split('').map((char, x) => {
            chars.add(char);
            if (!unpainted[char]) {
                unpainted[char] = [[y, x]];
            } else {
                unpainted[char].push([y, x]);
            }
            return char;
        });
    });

const dimY = grid.length;
const dimX = grid[0].length;

let unseen_chars = [...chars];

function neighbours(y, x) {
    return [
        [y-1, x], [y+1, x], [y, x-1], [y, x+1]
    ]
    .filter(([ny, nx]) => (ny >= 0 && ny < dimY) && (nx >= 0 && nx < dimX));
}

function paintFillGrouping() {
    while (unseen_chars.length > 0) {
        const char = unseen_chars.shift();

        const unseen_cells = unpainted[char].slice(0, 1);
        const matched_cells = [];

        // compare cells in unseen_cells enough times so that the group is completed
        while (unseen_cells.length > 0) {
            const [y, x] = unseen_cells.shift();
            if (grid[y][x] !== char) {
                continue;
            }
            matched_cells.push([y, x]);
            // erase grid to prevent cycling back
            grid[y][x] = ".";
            // try 4 neighbours of the current cell
            neighbours(y, x).forEach(([ny, nx]) => {
                if (grid[ny][nx] === char) {
                    // mark neighbour cell for visiting
                    unseen_cells.push([ny, nx]);
                }
            });
        }

        // generate a unique paint key, avoiding collisions
        const paintedKey = char + (100000 * Math.random()).toFixed(0);

        // unpack matched set of cells into painted[char] list
        if (matched_cells.length) {
            painted[paintedKey] = matched_cells;
            unpainted[char] = unpainted[char].filter(([y, x]) => !matched_cells.some(([py, px]) => py === y && px === x));
        }

        // keep only one instance of each coord
        painted[paintedKey] = painted[paintedKey].reduce((acc, [y, x]) => {
            if (!acc.some(([ay, ax]) => ay === y && ax === x)) {
                acc.push([y, x]);
            }
            return acc;
        }, []);

        // clean up emptied unpainted entries
        if (unpainted[char].length === 0) {
            delete unpainted[char];
        }

        // look for remnants of char that were not erased
        if (grid.some(row => row.some(c => c === char))) {
            unseen_chars.push(char);
        }
    }
}

function getPerimeter(char) {
    const total_sides = 4 * painted[char].length;
    const inner_sides = painted[char].reduce((acc, [y, x]) => {
        const nb_sides = neighbours(y, x)
            .filter(([ny, nx]) => painted[char].some(([py, px]) => py === ny && px === nx))
            .length;
        return acc + nb_sides;
    }, 0);
    return total_sides - inner_sides;
}

function getProduct1(char) {
    const area = painted[char].length;
    const peri = getPerimeter(char);
    return area * peri;
}

function getPerimeterCorners(char) {
    /*
     * 0 neighbours - count as 4 corners
     * 1 neighbour - count as 2 corners
     * 2 neighbours in a line - count as 0 corners
     * 2 neighbours not in line - check 1 diagonal cell - count 2 minus # painted diagonal corners
     * 3 neighbours - check 2 diagonal cells - count as 2 minus # painted diagonal corners
     * 4 neighbours - check 4 diagonal cells - count as 4 minus # painted diagonal cells
     */
    return painted[char].reduce((acc, [y, x]) => {
        const nbs = neighbours(y, x).filter(([ny, nx]) => painted[char].some(([py, px]) => py === ny && px === nx));
        let corners = 0;

        if (nbs.length === 0) {
            corners = 4;
        }
        else if (nbs.length === 1) {
            corners = 2;
        }
        else if (nbs.length === 2) {
            const [nb1, nb2] = nbs;
            const inline = nb1[0] === nb2[0] || nb1[1] === nb2[1];
            if (!inline) {
                // need to know if the sandwiched diagonal cell is painted or not
                const diag_nb = [[nb1[0], nb2[1]], [nb2[0], nb1[1]]].filter(([dy, dx]) => dy !== y && dx !== x)[0];
                const is_diag_nb_painted = painted[char].some(([py, px]) => py === diag_nb[0] && px === diag_nb[1]);
                corners = 2 - (is_diag_nb_painted ? 1 : 0);
            }
        }
        else if (nbs.length === 3) {
            // [0,1] [1,1] [2,1]
            //   ?   [1,2]   ?
            const [nb1, nb2, nb3] = nbs;
            // need to know which of the 2 diagonal cells are painted or not
            // for each pair of nbs there are 2 candidates, but only some are the real diagonal cells
            const diag_nbs = [
                [nb1[0], nb2[1]], [nb2[0], nb1[1]], // first pair
                [nb1[0], nb3[1]], [nb3[0], nb1[1]], // second pair
                [nb2[0], nb3[1]], [nb3[0], nb2[1]]  // third pair
            ].filter(([dy, dx]) => dy !== y && dx !== x); // should be 2

            const [diag_nb1, diag_nb2] = diag_nbs;
            const is_diag_nb1_painted = painted[char].some(([py, px]) => py === diag_nb1[0] && px === diag_nb1[1]);
            const is_diag_nb2_painted = painted[char].some(([py, px]) => py === diag_nb2[0] && px === diag_nb2[1]);
            corners = 2 - (is_diag_nb1_painted ? 1 : 0) - (is_diag_nb2_painted ? 1 : 0);
        }
        else if (nbs.length === 4) {
            // need to know which of the 4 diagonal cells are painted or not
            const diag_nbs = [
                [y-1, x-1], [y-1, x+1], [y+1, x-1], [y+1, x+1]
            ];
            const [diag_nb1, diag_nb2, diag_nb3, diag_nb4] = diag_nbs;
            const is_diag_nb1_painted = painted[char].some(([py, px]) => py === diag_nb1[0] && px === diag_nb1[1]);
            const is_diag_nb2_painted = painted[char].some(([py, px]) => py === diag_nb2[0] && px === diag_nb2[1]);
            const is_diag_nb3_painted = painted[char].some(([py, px]) => py === diag_nb3[0] && px === diag_nb3[1]);
            const is_diag_nb4_painted = painted[char].some(([py, px]) => py === diag_nb4[0] && px === diag_nb4[1]);
            corners = 4 - (is_diag_nb1_painted ? 1 : 0) - (is_diag_nb2_painted ? 1 : 0) - (is_diag_nb3_painted ? 1 : 0) - (is_diag_nb4_painted ? 1 : 0);
        }

        return acc + corners;
    }, 0);
}

function getProduct2(char) {
    const area = painted[char].length;
    const corn = getPerimeterCorners(char);
    return area * corn;
}

// begin work
paintFillGrouping();

const p1 = Object.keys(painted)
    .map(char => getProduct1(char))
    .reduce((acc, val) => acc + val, 0);

// part1 - find contiguous areas of each char. sum area * perimeter
p('P1:', p1);

const p2 = Object.keys(painted)
    .map(char => getProduct2(char))
    .reduce((acc, val) => acc + val, 0);

// part2 - find contiguous areas of each char. sum area * corners
p('P2:', p2);


// P1: 1573474
// P2: 966476