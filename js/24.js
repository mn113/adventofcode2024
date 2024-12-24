const fs = require('fs');
const p = console.log;

const INPUTBITS = 45;
const OUTPUTBITS = 46;

// { k => v: integer }
let known;

// [[wire1, wire2, operator, output]]
let gates;

// Set(string)
let unknown = new Set();

// Parse input
fs.readFileSync('../inputs/input24.txt', 'utf-8')
    .split("\n\n")
    .forEach((part, i) => {
        if (i === 0) {
            known = part.split('\n').reduce((acc, line) => {
                const [k, v] = line.split(': ');
                return Object.assign(acc, {
                    [k]: parseInt(v)
                });
            }, {});

        }
        else if (i === 1) {
            gates = part.split("\n").map(line => {
                const [wire1, operator, wire2, arrow, output] = line.split(/\s+/);
                if (output.startsWith('z')) {
                    unknown.add(output);
                }
                return [wire1, wire2, operator, output];
            });
        }
    });

function logic(v1, v2, operator) {
    if (operator === 'AND') {
        return v1 & v2;
    }
    else if (operator === 'OR') {
        return v1 | v2;
    }
    else if (operator === 'XOR') {
        return (v1 == 1 || v2 == 1) && v1 !== v2 ? 1 : 0;
    }
}

function parseWiresToDecimal(prefix, known1) {
    const binary = Object.keys(known1)
        .filter(k => k.startsWith(prefix))
        .sort()
        .reverse()
        .map(k => known1[k])
        .join('')

    return parseInt(binary, 2);
}

function decimalToWires(dec, prefix) {
    return Number(dec).toString(2)
        .padStart(prefix === 'z' ? OUTPUTBITS : INPUTBITS, '0')
        .split('')
        .reverse()
        .map((d,i) => [toPrefixed(i, prefix), parseInt(d)])
}

function toPrefixed(index, prefix) {
    return prefix + index.toString().padStart(2, '0');
}

function swapOutputWires(w1, w2) {
    gates.find(([wire1, wire2, operator, output]) => output === w1)[3] = 'temp';
    gates.find(([wire1, wire2, operator, output]) => output === w2)[3] = w1;
    gates.find(([wire1, wire2, operator, output]) => output === 'temp')[3] = w2;
}

function calculateResult(known) {
    // clone globals
    known1 = Object.assign({}, known);
    unknown1 = new Set(unknown);

    let i = 0;
    while (unknown1.size > 0 && i < 1000) {
        gates.forEach(([wire1, wire2, operator, output]) => {
            if (!(output in known1) && wire1 in known1 && wire2 in known1) {
                known1[output] = logic(known1[wire1], known1[wire2], operator);
                //p(`${wire1} (${known1[wire1]}) ${operator} ${wire2} (${known1[wire2]}) => ${output} (${known1[output]})`);
                unknown1.delete(output);
            }
        });
        i++;
    }
    return known1;
}


// Part 1 - find the number represented by the z wires after following logic gates

const resP1 = calculateResult(Object.assign({}, known));
p('P1:', parseWiresToDecimal('z', resP1));

// Part 2 - find 4 pairs of logic gates whose outputs should be swapped
// to cause proper addition of inputs: xn...x0 + yn...y0 = zn...z0

function nodeColor(wire) {
    return wire.startsWith('x') ? 'red' : wire.startsWith('y') ? 'blue' : wire.startsWith('z') ? 'green' : 'black';
}

function edgeColor(operator) {
    return {
        'AND': 'blue',
        'XOR': 'red',
        'OR': 'black'
    }[operator];
}

function toGraphviz(gates, results, targetWires) {
    const nodes = Object.entries(results).reduce((acc, [k, v]) => {
        let colorAttr = `color="${nodeColor(k)}"`;
        let xlabelAttr = `xlabel="${v}"`;
        let fillAttrs = '';
        if (k in targetWires && v !== targetWires[k]) {
            fillAttrs = `style=filled,fillcolor=yellow`;
        }
        let attrs = [colorAttr, xlabelAttr, fillAttrs].filter(Boolean).join(',');
        return [
            ...acc,
            `${k} [${attrs}]`
        ];
    }, []);
    const edges = gates.reduce((acc, [wire1, wire2, operator, output]) => {
        return [
            ...acc,
            `${wire1} -> ${output} [taillabel="${operator}",color="${edgeColor(operator)}"]`,
            `${wire2} -> ${output} [taillabel="${operator}",color="${edgeColor(operator)}"]`
        ];
    }, []);
    const text = 'digraph {\n' + nodes.join('\n') + '\n\n' + edges.join('\n') + '\n}';
    fs.writeFileSync('24.dot', text);
}

function testAdd(xDecimal, yDecimal) {
    const inputs = Object.assign({}, known);

    const xWires = decimalToWires(xDecimal, 'x');
    const yWires = decimalToWires(yDecimal, 'y');

    xWires.forEach(([k, v]) => inputs[k] = v);
    yWires.forEach(([k, v]) => inputs[k] = v);

    // Solution: 4 swaps found by inspection of Graphviz graph before corrections
    swapOutputWires('z11', 'rpv');
    swapOutputWires('ctg', 'rpb');
    swapOutputWires('z31', 'dmh');
    swapOutputWires('z38', 'dvq');
    p('P2:', ['z11', 'ctg', 'z31', 'z38', 'rpv', 'rpb', 'dmh', 'dvq'].sort().join(','))

    const res = calculateResult(inputs);
    const xInputDecimal = parseWiresToDecimal('x', res);
    const yInputDecimal = parseWiresToDecimal('y', res);
    const zOutputDecimal = parseWiresToDecimal('z', res);
    p(`${xInputDecimal} + ${yInputDecimal} = ${zOutputDecimal}`, (xInputDecimal + yInputDecimal) === zOutputDecimal);

    const targetOutputDecimal = xInputDecimal + yInputDecimal;
    const targetWires = Object.fromEntries(decimalToWires(targetOutputDecimal, 'z'));

    toGraphviz(gates, res, targetWires);
}

testAdd(2 ** INPUTBITS - 1, 0); // add all 1s to all 0s to most easily test the circuit

// https://www.elprocus.com/ripple-carry-adder-working-types-and-its-applications/

// P1: 59336987801432
// P2: ctg,dmh,dvq,rpb,rpv,z11,z31,z38
