const fs = require('fs');

const p = console.log;

const codes = fs.readFileSync('../inputs/input21.txt', 'utf-8')
    .split("\n\n")
    [0]
    .split('\n');

// Numeric Keypad - to avoid !!!, move U must precede move L, and move R must precede move D
// +---+---+---+
// | 7 | 8 | 9 |
// +---+---+---+
// | 4 | 5 | 6 |
// +---+---+---+
// | 1 | 2 | 3 |
// +---+---+---+
//  !!!| 0 | A |
//     +---+---+

// Directional Keypad - to avoid !!!, move D must precede move L, and move R must precede move U
//     +---+---+
//  !!!| ^ | A |
// +---+---+---+
// | < | v | > |
// +---+---+---+

function getNumericKeypadSequenceHardcoded(code = '') {
    return `A${code}` // start key
        // pairs from test input
        .replace('A0', 'A<0')
        .replace('A9', 'A^^^9')
        .replace('A1', 'A^<<1') // <<^ = panic
        .replace('A4', 'A^^<<4') // <<^^ = panic
        .replace('A3', 'A^3')
        .replace('02', '0^2')
        .replace('29', '2^^>9')
        .replace('98', '9<8')
        .replace('80', '8vvv0')
        .replace('0A', '0>A')
        .replace('17', '1^^7')
        .replace('71', '7vv1')
        .replace('45', '4>5')
        .replace('56', '5>6')
        .replace('6A', '6vvA')
        .replace('37', '3<<^^7')
        .replace('79', '7>>9')
        .replace('9A', '9vvvA')
        // pairs from real input
        .replace('A2', 'A<^2') //?
        .replace('A3', 'A^3')
        .replace('A4', 'A^^<<4') // <<^^ = panic
        .replace('A5', 'A<^^5') // significant
        .replace('20', '2v0')
        .replace('08', '0^^^8')
        .replace('8A', '8vvv>A') //?
        .replace('58', '5^8')
        .replace('86', '8v>6') //?
        .replace('6A', '6vvA')
        .replace('34', '3<<^4') //?
        .replace('41', '4v1')
        .replace('1A', '1>>vA') // v>> = panic?
        .replace('46', '4>>6')
        .replace('63', '6v3')
        .replace('59', '5^>9') // no difference
        .replace('93', '9vv3')
        .replace('3A', '3vA')
        // clean up
        .replace(/\d/g, 'A')
        .replace(/^A/g, '');
}

function getDirectionalKeypadSequenceFromPair(lastSequence) {
    // keys: initial button + end button
    // values: sequence of moves
    const mapping = {
        '^^': '',
        '^A': '>',
        '^<': 'v<',
        '^v': 'v',
        '^>': 'v>',
        'A^': '<',
        'AA': '',
        'A<': 'v<<',
        'Av': '<v',
        'A>': 'v',
        '<^': '>^',
        '<A': '>>^',
        '<<': '',
        '<v': '>',
        '<>': '>>',
        'v^': '^',
        'vA': '^>',
        'v<': '<',
        'vv': '',
        'v>': '>',
        '>^': '<^',
        '>A': '^',
        '><': '<<',
        '>v': '<',
        '>>': ''
    };
    if (!(lastSequence in mapping)) {
        throw new Error(`Unknown last sequence: ${lastSequence}`);
    }
    return mapping[lastSequence] + 'A';
}

function mapPairsToSequencesAndCount(movesWithCount) {
    const newMovesWithCount = {};
    for (const [move, count] of Object.entries(movesWithCount)) {
        const moveSequence = 'A' + getDirectionalKeypadSequenceFromPair(move);
        for (let i = 0; i < moveSequence.length - 1; i++) {
            const move = moveSequence.slice(i, i+2);
            newMovesWithCount[move] ||= 0;
            // increment not with 1, but with the count from the previous step
            newMovesWithCount[move] += count;
        }
    }
    return newMovesWithCount;
}

function getSequenceLength(code, keypadsAmount = 2) {
    p('code:', code)
    let movesWithCount = {};

    // First keypad is a unique type
    let seq1 = 'A' + getNumericKeypadSequenceHardcoded(code);
    for (let i = 0; i < seq1.length - 1; i++) {
        const move = seq1.slice(i, i+2);
        movesWithCount[move] ||= 0;
        movesWithCount[move]++;
    }

    // Remaining keypads are all the directional type
    let keypads = 1
    while (keypads <= keypadsAmount) {
        movesWithCount = mapPairsToSequencesAndCount(movesWithCount);
        keypads++;
    }

    return Object.values(movesWithCount).reduce((a, b) => a + b, 0);
}

function getSequenceLengths(codes, keypadsAmount) {
    return codes.map(code => parseInt(code, 10) * getSequenceLength(code, keypadsAmount));
}

// Part 1 - find the shortest sequence of button presses on the third keypad to enter each code on the first keypad
p('P1:', getSequenceLengths(codes).reduce((a, b) => a + b));

// Part 2 - find the shortest sequence of button presses on the 25th keypad to enter each code on the first keypad
p('P2:', getSequenceLengths(codes, 25).reduce((a, b) => a + b));

// P1: 155252
// P2: 195664513288128