# Breakdown
Example input:
```q
x:enlist"..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..##"
x,:enlist"#..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###"
x,:enlist".######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#."
x,:enlist".#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#....."
x,:enlist".#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.."
x,:enlist"...####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#....."
x,:enlist"..##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#"
x,:enlist""
x,:enlist"#..#."
x,:enlist"#...."
x,:enlist"##..#"
x,:enlist"..#.."
x,:enlist"..###"

```

## Common
We split the input into two parts:
```q
q)a:"\n\n"vs"\n"sv x
q)a
"..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..##\n#.."
"#..#.\n#....\n##..#\n..#..\n..###\n"
```
We extract the "program" part, getting rid of any newlines and converting it to booleans:
```q
q)prog:"#"=a[0]except"\n"
q)prog
001010011111010101011101100000111011010011101111001111100100001001001100111001111..
```
We cut the map into lines and convert to booleans:
```q
q)map:"#"="\n"vs a 1
q)map
10010b
10000b
11001b
00100b
00111b
```
We do an iteration using a plain `do` loop. The number of iterations is a parameter to our function.
```q
    step:0;
    do[times;
```
The body of an iteration is a simulation of a cellular automaton similar to day 11.

A nasty trick of this puzzle is that since the entire endless grid must follow the rules, if the
first element of the enhancement array is on, all the cells in the endless void will turn on. As
this would cause the answer to be infinite, the last element of the enhancement array must be off,
causing the cells to alternate between on and off between generations. The impact of this on the
simulation is that when padding the array with more elements to make sure there are enough elements
on the edges to not lose information, we don't just fill with zeros like in a normal cellular
automaton, instead we keep track of the state of the outer cells and populate the padding from that
value. The value is calculated as follows: if the first element of `prog` is true, take the step
counter modulo 2 and convert it to boolean, otherwise the value is always false.
```q
q)edge:$[prog 0;`boolean$step mod 2;0b]
q)edge
0b
```
We create the padded map:
```q
q)map1:{[edge;x]row:count[x 0]#edge;enlist[row],x,enlist[row]}[edge;edge,/:map,\:edge]
q)map1
0000000b
0100100b
0100000b
0110010b
0001000b
0001110b
0000000b
```
We generate all 9 shifted versions of the map, including the non-shifted version. Note that the
order is important because of how the map contents are transformed into indices into the program,
so we don't extract the 0 rotation to the end as with day 11.
```q
q)maps:raze -1 0 1 rotate/:\:-1 0 1 rotate/:\:map1
q)maps
0000000b 0000000b 0010010b 0010000b 0011001b 0000100b 0000111b
0000000b 0000000b 0100100b 0100000b 0110010b 0001000b 0001110b
0000000b 0000000b 1001000b 1000000b 1100100b 0010000b 0011100b
0000000b 0010010b 0010000b 0011001b 0000100b 0000111b 0000000b
0000000b 0100100b 0100000b 0110010b 0001000b 0001110b 0000000b
0000000b 1001000b 1000000b 1100100b 0010000b 0011100b 0000000b
0010010b 0010000b 0011001b 0000100b 0000111b 0000000b 0000000b
0100100b 0100000b 0110010b 0001000b 0001110b 0000000b 0000000b
1001000b 1000000b 1100100b 0010000b 0011100b 0000000b 0000000b
```
We have a 3-dimensional array with the rotation index being the first coordinate. We have to shift
this coordinate to the last position. Keep in mind that `flip` swaps the first coordinates, and
`each` moves the operation down one level, so we have to `flip` first followed by `flip each` to
do the shift.
```q
q)flip each flip maps
000000001b 000000010b 000000100b 000000001b 000000010b 000000100b 000000000b
000001001b 000010010b 000100100b 000001000b 000010000b 000100000b 000000000b
001001001b 010010011b 100100110b 001000100b 010000001b 100000010b 000000100b
001001000b 010011000b 100110001b 000100010b 000001100b 000010000b 000100000b
001000000b 011000000b 110001001b 100010011b 001100111b 010000110b 100000100b
000000000b 000000000b 001001000b 010011000b 100111000b 000110000b 000100000b
000000000b 000000000b 001000000b 011000000b 111000000b 110000000b 100000000b
```
We convert these boolean lists to indices into `prog` using `2 sv`, applied two levels deep:
```q
q)2 sv/:/:flip each flip maps
1  2   4   1   2   4   0
9  18  36  8   16  32  0
73 147 294 68  129 258 4
72 152 305 34  12  16  32
64 192 393 275 103 134 260
0  0   72  152 312 48  32
0  0   64  192 448 384 256
```
We then index into `prog` to get the updated map:
```q
q)map:prog 2 sv/:/:flip each flip maps
q)map
0110110b
1001010b
1101001b
1111001b
0100110b
0011001b
0001010b
```
We increase the step counter:
```q
    step+:1;
```
This ends the iteration.
```q
    ];
```
The answer is the sum of the elements of the map.
```q
q)map
000000010b
010010100b
101000111b
100011010b
100000101b
010111110b
001011111b
000110110b
000011100b
q)sum sum map
35i
```

## Part 1
We invoke the above function with an iteration count of 2.

## Part 2
We invoke the above function with an iteration count of 50.
