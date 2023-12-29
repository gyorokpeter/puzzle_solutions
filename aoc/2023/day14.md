# Breakdown

Example input:
```q
x:();
x,:"\n"vs"O....#....\nO.OO#....#\n.....##...\nOO.#O....O\n.O.....O#.\nO.#..O.#.#";
x,:"\n"vs"..O..#O..O\n.......O..\n#....###..\n#OO..#....";
```

## Common
Rolling all the rocks west can be implemented using a simple trick: cut each line on `"#"`, sort the pieces in descending order (so `"O"` comes before `"."`) and then merge them back. Rolling east is as easy but sorting in ascending order.
```q
.d14.west:{"#"sv/:desc each/:"#"vs/:x}
.d14.east:{"#"sv/:asc each/:"#"vs/:x}
q).d14.west x
"O....#...."
"OOO.#....#"
".....##..."
"OO.#OO...."
"OO......#."
"O.#O...#.#"
"O....#OO.."
"O........."
"#....###.."
"#OO..#...."
q).d14.east x
"....O#...."
".OOO#....#"
".....##..."
".OO#....OO"
"......OO#."
".O#...O#.#"
"....O#..OO"
".........O"
"#....###.."
"#..OO#...."
```
To calculate the weight, we first compare the map to `"O"` to generate a truth matrix, then multiply each row with the corresponding weight (subtractin the row index from the number of rows):
```q
.d14.weight:{sum sum(count[x]-til count x)*x="O"}
q).d14.weight x
104
```

## Part 1
The trick involving sorting only works horizontally, but we can easily use it vertically by flipping the map first and then flipping it back after the operation:
```q
q)flip .d14.west flip x
"OOOO.#.O.."
"OO..#....#"
"OO..O##..O"
"O..#.OO..."
"........#."
"..#....#.#"
"..O..#.O.O"
"..O......."
"#....###.."
"#....#...."
q).d14.weight flip .d14.west flip x
136
```

## Part 2
We define a `step` function which applies the rolling functions in all four directions:
```q
step:{
    x:flip .d14.west flip x;
    x:.d14.west x;
    x:flip .d14.east flip x;
    x:.d14.east x;
x}
```
Considering the large number of steps, we expect there to be a loop eventually, so we keep track of the state of the map after each step and iterate until we run into a configuration that we have already seen:
```q
q)a:x;seen:();while[not any b:a~/:seen;seen,:enlist a;a:step a]
q)a
".....#...."
"....#...O#"
".....##..."
"..O#......"
".....OOO#."
".O#...O#.#"
"....O#...O"
".......OOO"
"#...O###.O"
"#.OOO#...O"
q)seen
"O....#...." "O.OO#....#" ".....##..." "OO.#O....O" ".O.....O#." "O.#..O.#.#"..
".....#...." "....#...O#" "...OO##..." ".OO#......" ".....OOO#." ".O#...O#.#"..
".....#...." "....#...O#" ".....##..." "..O#......" ".....OOO#." ".O#...O#.#"..
".....#...." "....#...O#" ".....##..." "..O#......" ".....OOO#." ".O#...O#.#"..
".....#...." "....#...O#" ".....##..." "..O#......" ".....OOO#." ".O#...O#.#"..
".....#...." "....#...O#" ".....##..." "...#......" ".....OOO#." ".O#...O#.#"..
".....#...." "....#...O#" ".....##..." "...#......" ".....OOO#." ".O#...O#.#"..
".....#...." "....#...O#" ".....##..." "..O#......" "......OO#." ".O#...O#.#"..
".....#...." "....#...O#" ".....##..." "..O#......" "......OO#." ".O#...O#.#"..
".....#...." "....#...O#" ".....##..." "..O#......" ".....OOO#." ".O#...O#.#"..
```
We can find the loop start position by looking at what index the state appeared first (this is why we saved the result of the test in the `b` variable). Then the loop length is the total number of seen states minus the index of the loop start.
```q
q)loopStart:first where b; loopLen:count[seen]-loopStart
q)loopStart
3
q)loopLen
7
```
We can find the final state using some modular arithmetic, and then find its weight:
```q
q)loopStart+(1000000000-loopStart)mod loopLen
6
q)seen loopStart+(1000000000-loopStart)mod loopLen
".....#...."
"....#...O#"
".....##..."
"...#......"
".....OOO#."
".O#...O#.#"
"....O#...O"
"......OOOO"
"#....###.O"
"#.OOO#..OO"
q).d14.weight seen loopStart+(1000000000-loopStart)mod loopLen
64
```

(It's strange that we end the cycle after an east move but then still care about the load on the _north_ support beams. It would be a trivial change to reorder the `step` function to finish with a north move.)
