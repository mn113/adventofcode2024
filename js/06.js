const fs = require('fs');

const p = console.log

/**
 * @typedef {string[][]} Grid
 */
/**
 * @typedef {[Number, Number]} Coord
 */

const BLOCK = '#';
const SPACE = '.';
const OOB = null;

const VEC_N = [-1, 0];
const VEC_S = [1, 0];
const VEC_E = [0, 1];
const VEC_W = [0, -1];

let initialGuardPosYX = [];
const initialHeadingYX = VEC_N;
let guardPosYX; // resettable
let headingYX; // resettable
let visited = {}; // resettable
const empties = new Set();

/** @type {Grid} */
const grid = fs.readFileSync('../inputs/input06.txt', 'utf-8')
    .split("\n")
    .map((line, gy) => {
        const lineChars = line.split('');
        lineChars.forEach((char, gx) => {
            if (char === BLOCK) return;
            else if (char === '^') {
                // found guard; erase guard
                initialGuardPosYX = [gy, gx];
                lineChars[gx] = SPACE;
            }
            empties.add([gy, gx]);
        });
        return lineChars;
    });

const dimY = grid.length;
const dimX = grid[0].length;


/**
 * Get string key encoding guard's position and heading
 * @return {string}
 */
function getKey() {
    return `${guardPosYX}_${headingYX}`;
}

/**
 * Check what is 1 step in front of the guard
 * @param {Grid} usedGrid
 * @return {string|null}
 */
function lookAhead(usedGrid) {
    const aheadY = guardPosYX[0] + headingYX[0];
    const aheadX = guardPosYX[1] + headingYX[1];
    if (0 <= aheadY && aheadY < dimY) {
        if (0 <= aheadX && aheadX < dimX) {
            return usedGrid[aheadY][aheadX];
        }
    }
    return OOB;
}

/**
 * Compute new heading vector for the guard
 */
function turnRight() {
    switch (headingYX.toString()) {
        case VEC_N.toString():
            headingYX = VEC_E;
            break
        case VEC_S.toString():
            headingYX = VEC_W;
            break
        case VEC_E.toString():
            headingYX = VEC_S;
            break
        case VEC_W.toString():
            headingYX = VEC_N;
            break
    }
}

/**
 * Guard takes a step; log position
 */
function visitAndStep() {
    visited[getKey()] = true; // log pre-move location with exit heading
    guardPosYX[0] += headingYX[0];
    guardPosYX[1] += headingYX[1];
}

/**
 * Just log position
 */
function visitOnly() {
    visited[getKey()] = true;
}

function resetSimulation() {
    guardPosYX = [...initialGuardPosYX];
    headingYX = [...initialHeadingYX];
    visited = {};
}

/**
 * Run the guard simulation once (part 1)
 * @param {Grid} usedGrid
 * @param {number} maxSteps
 */
function runSimulationP1(usedGrid, maxSteps = 6000) {
    resetSimulation();
    let i = 0;
    while (i < maxSteps) {
        i++;

        // check for looping
        if (getKey() in visited) {
            return 0;
        }

        const ahead = lookAhead(usedGrid);
        if (ahead === BLOCK){
            turnRight(); // updates headingYX
        }
        else if (ahead === SPACE) {
            visitAndStep(); // updates guardPosYX, visited
        }
        else if (ahead === OOB) {
            visitOnly(); // updates visited
            break;
        };
    }
    // count only visited locations, not headings
    return new Set(Object.keys(visited).map(k => k.split("_")[0])).size;
}

// Part 1 - find out how many squares the guard will visit before leaving the grid
const p1 = runSimulationP1(grid);
p(`Part 1: visited ${p1} squares`); // P1: 4903


/**
 * Find the farthest empty space in the heading direction
 * @param {Grid} usedGrid
 * @return {Coord|null}
 */
function lookFarAhead(usedGrid) {
    const [gy, gx] = guardPosYX;
    const headingStr = headingYX.toString();
    let row, col;
    let blockX, blockY;
    switch (headingStr) {
        case VEC_N.toString():
            col = usedGrid.map(r => r[gx]);
            blockY = col.lastIndexOf(BLOCK, gy);
            return blockY > -1 ? [blockY + 1, gx] : OOB;

        case VEC_S.toString():
            col = usedGrid.map(r => r[gx]);
            blockY = col.indexOf(BLOCK, gy);
            return blockY > -1 ? [blockY - 1, gx] : OOB;

        case VEC_E.toString():
            row = usedGrid[gy];
            blockX = row.indexOf(BLOCK, gx);
            return blockX > -1 ? [gy, blockX - 1] : OOB;

        case VEC_W.toString():
            row = usedGrid[gy];
            blockX = row.lastIndexOf(BLOCK, gx);
            return blockX > -1 ? [gy, blockX + 1] : OOB;

        default:
            throw new Error(`bad headingYX: ${headingYX}`)
    }
}

/**
 * Run the guard simulation once (part 1)
 * @param {Grid} usedGrid
 * @param {number} maxSteps
 */
function runSimulationP2(usedGrid, maxSteps = 6000) {
    resetSimulation();
    let i = 0;
    while (i < maxSteps) {
        i++;

        const farAhead = lookFarAhead(usedGrid);
        if (farAhead === OOB) {
            break;
        }
        else {
            // fast-forward
            guardPosYX = [...farAhead]; // travel in a line
            turnRight(); // updates headingYX

            // check for looping
            if (getKey() in visited) {
                return 0; // means infinite loop
            }

            visitOnly();
        }
    }
    return 1; // means no infinite loop
}

// Part 2 - find out how many of the empty squares, if a block is placed, will make the guard loop infinitely
const p2Positions = new Set();
for (let y = 0; y < dimY; y++) {
    for (let x = 0; x < dimX; x++) {
        if (grid[y][x] === SPACE) {
            const clonedGrid = structuredClone(grid);
            // place fake block and run simulation
            clonedGrid[y][x] = BLOCK;
            if (runSimulationP2(clonedGrid, 1000) === 0) {
                p2Positions.add([y, x])
            }
        }
    }
}
p(`Part 2: infinite loop in ${p2Positions.size} cases (of ${empties.size})`); // P2: 1911
