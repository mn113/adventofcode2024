const fs = require('fs');

const p = console.log;

const zeros = [];
const nines = [];

const grid = fs.readFileSync('../inputs/input10.txt', 'utf-8')
    .split("\n")
    .map((line, gy) => {
        const lineChars = line.split('');
        lineChars.forEach((char, gx) => {
            if (char === '0') {
                zeros.push([gy, gx]);
            }
            else if (char === '9') {
                nines.push([gy, gx]);
            }
        });
        return lineChars.map(c => parseInt(c));
    });

const dimY = grid.length;
const dimX = grid[0].length;


class State {
    constructor(y, x, history) {
        this.y = y;
        this.x = x;
        this.history = history || `[${y}][${x}]=${grid[y][x]}; `;
    }
    update(y, x) {
        this.y = y;
        this.x = x;
        this.history += `[${y}][${x}]=${grid[y][x]}; `;
    }
    clone() {
        return new State(this.y, this.x, this.history);
    }
}


function neighbours(y, x) {
    return [
        [y-1, x], [y+1, x], [y, x-1], [y, x+1],
    ]
    .filter(([ny, nx]) => (ny >= 0 && ny < dimY) && (nx >= 0 && nx < dimX));
}

function existsPathBetween(start, end) {
    const [y0, x0] = start;
    const [y1, x1] = end;
    // DFS
    const unseen = [[y0, x0, grid[y0][x0]]];
    while (unseen.length > 0) {
        const [cy, cx, cval] = unseen.shift();
        if (cy === y1 && cx === x1) {
            return true;
        }
        const nbs = neighbours(cy, cx)
            .filter(([ny, nx]) => (
                grid[ny][nx] === cval + 1
            ))
            .map(([ny, nx]) => (
                [ny, nx, grid[ny][nx]]
            ));
        unseen.push(...nbs);
    }
    return false;
}

function countPathsBetween(start, end) {
    const [y0, x0] = start;
    const [y1, x1] = end;
    const paths = new Set();
    // exhaustive search
    const unseen = [new State(y0, x0)];
    while (unseen.length > 0) {
        const currentState = unseen.shift();
        if (currentState.y === y1 && currentState.x === x1) {
            paths.add(currentState.history);
        }
        const nbs = neighbours(currentState.y, currentState.x).filter(([ny, nx]) => (
            grid[ny][nx] === grid[currentState.y][currentState.x] + 1
        ));
        nbs.forEach(([ny, nx]) => {
            const state = currentState.clone();
            state.update(ny, nx);
            unseen.push(state);
        });
    }
    return paths.size;
}

const sum = (a, b) => a + b;

function getTrailheadSimpleScore(start) {
    return nines.filter(end => {
        return existsPathBetween(start, end);
    }).length;
}

function getTrailheadMultiScore(start) {
    return nines.map(end => {
        return countPathsBetween(start, end);
    }).reduce(sum, 0);
}

// part1 - sum the scores of each trailhead (0) which is how many peaks (9) we can walk to from it
p('P1:', zeros.map(getTrailheadSimpleScore).reduce(sum, 0));

// part2 - sum the scores of each trailhead (0) which is how many distinct walks to any peak (9) we can do from it
p('P2:', zeros.map(getTrailheadMultiScore).reduce(sum, 0));


// P1: 733
// P2: 1514