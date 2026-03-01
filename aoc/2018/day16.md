# Breakdown
Example input:
```q
q)md5"\n"sv x
0x1bc2f84b5af4ae4a722222996248760b
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

## Common
We define helper functions for bitwise AND and OR. We put these into the `.q` namespace to make them
globally available. Reailly these should be built in.
```q
.q.bitand:{0b sv (0b vs x)and 0b vs y};
.q.bitor:{0b sv (0b vs x)or 0b vs y};
```

### Input parsing
The `d16` function takes the input and returns a tuple containing the code, before, after blocks and
the test program.

We find the splitting point between the experiments and the program by taking the moving sum of the
string lengths with a window size of 3, and checking when the result is zero:
```q
q)split:first where 0=3 msum count each x
q)split
3261
```
We cut the input at this point, and also cut the first part into sublists of length 4 to find the
lines of each experiment:
```q
q)eff:4 cut -1_split#x
q)eff
"Before: [0, 2, 2, 2]" "11 3 3 3" "After:  [0, 2, 2, 0]" ""
"Before: [3, 2, 1, 1]" "11 2 3 3" "After:  [3, 2, 1, 0]" ""
"Before: [1, 2, 2, 1]" "5 3 2 2"  "After:  [1, 2, 1, 1]" ""
"Before: [1, 0, 2, 2]" "14 0 2 2" "After:  [1, 0, 0, 2]" ""
..
```
We fetch the code from the elements at index 1 in each row, split them on spaces and convert them
into integers:
```q
q)code:"J"$" "vs/:eff[;1]
q)code
11 3 3 3
11 2 3 3
5  3 2 2
14 0 2 2
..
```
For the before and after values, we cut on the brackets to isolate the number list, cut again on
`", "` and then convert to integers:
```q
q)before:"J"$", "vs/:first each "]"vs/:last each"["vs/:eff[;0]
q)after:"J"$", "vs/:first each "]"vs/:last each"["vs/:eff[;2]
q)before
0 2 2 2
3 2 1 1
1 2 2 1
1 0 2 2
..
q)after
0 2 2 0
3 2 1 0
1 2 1 1
1 0 0 2
..
```
For the test program, we cut on spaces again as with the code:
```q
q)test:"J"$" "vs/:(1+split)_x
q)test
14 3 3 2
14 3 3 0
14 2 2 1
13 0 2 1
..
```
We return a tuple with all four results:
```q
q)(code;before;after;test)
(11 3 3 3;11 2 3 3;5 3 2 2;14 0 2 2;10 1 3 3;14 0 2 3;6 2 2 0;13 1 2 0;10 2 3 1;3 2 3 0;4 1 0 2;7 ..
(0 2 2 2;3 2 1 1;1 2 2 1;1 0 2 2;3 2 3 3;1 1 2 1;2 1 2 0;1 1 3 1;1 1 1 3;3 3 0 2;2 1 1 0;2 3 3 2;1..
(0 2 2 0;3 2 1 0;1 2 1 1;1 0 0 2;3 2 3 0;1 1 2 0;1 1 2 0;0 1 3 1;1 0 1 3;1 3 0 2;2 1 0 0;1 3 3 2;1..
(14 3 3 2;14 3 3 0;14 2 2 1;13 0 2 1;4 1 2 1;1 3 1 3;14 2 3 1;14 2 0 0;6 0 2 0;4 0 3 0;1 0 3 3;14 ..
```

### Opcode definitions
We create a dictionary of the opcodes. Each of them takes a single operation (e.g. one element of
`code` or `test`) and the register state, and returns the modified register state. The functions are
straightforward simulations of the respective instructions. Perhaps the only caveat is with the
comparison operators: since they return booleans, we have to convert them to `long` before putting
them into the register state to avoid a type error.
```q
d16ins:()!();
d16ins[`addr]:{[op;reg]reg[op 3]:reg[op 1]+reg[op 2];reg};
d16ins[`addi]:{[op;reg]reg[op 3]:reg[op 1]+op 2;reg};
d16ins[`mulr]:{[op;reg]reg[op 3]:reg[op 1]*reg[op 2];reg};
d16ins[`muli]:{[op;reg]reg[op 3]:reg[op 1]*op 2;reg};
d16ins[`banr]:{[op;reg]reg[op 3]:reg[op 1] bitand reg[op 2];reg};
d16ins[`bani]:{[op;reg]reg[op 3]:reg[op 1] bitand op 2;reg};
d16ins[`borr]:{[op;reg]reg[op 3]:reg[op 1] bitor reg[op 2];reg};
d16ins[`bori]:{[op;reg]reg[op 3]:reg[op 1] bitor op 2;reg};
d16ins[`setr]:{[op;reg]reg[op 3]:reg[op 1];reg};
d16ins[`seti]:{[op;reg]reg[op 3]:op 1;reg};
d16ins[`gtir]:{[op;reg]reg[op 3]:`long$op[1]>reg[op 2];reg};
d16ins[`gtri]:{[op;reg]reg[op 3]:`long$reg[op 1]>op 2;reg};
d16ins[`gtrr]:{[op;reg]reg[op 3]:`long$reg[op 1]>reg[op 2];reg};
d16ins[`eqir]:{[op;reg]reg[op 3]:`long$op[1]=reg[op 2];reg};
d16ins[`eqri]:{[op;reg]reg[op 3]:`long$reg[op 1]=op 2;reg};
d16ins[`eqrr]:{[op;reg]reg[op 3]:`long$reg[op 1]=reg[op 2];reg};
```

## Part 1
We use the helper function to parse the input, then extract the needed components:
```q
q)cba:d16 x;code:cba 0;before:cba 1;after:cba 2;
```
The helper function `d16match` checks which instructions match each experiment. It takes four
parameters: the instruction list (which is the same for every invocation) and one element from each
of the `code`, `before` and `after` lists. This allows calling it with `'` (each) on the three
lists, processing them 3-tuple-wise.
```q
    d16match[key d16ins]'[code;before;after]
```
Example for the parameters:
```q
q)ins:key d16ins
q)c:first code
q)bf:first before
q)af:first after
q)ins
`addr`addi`mulr`muli`banr`bani`borr`bori`setr`seti`gtir`gtri`gtrr`eqir`eqri`eqrr
q)c
11 3 3 3
q)bf
0 2 2 2
q)af
0 2 2 0
```
The helper function invokes each of the instruction handlers with the code and the before state,
invoking it with `each` on a dictionary such that the result is a mapping from the instructions to
the resulting register values:
```q
q)paf:.[;(c;bf)]each ins#d16ins
q)paf
addr| 0 2 2 4
addi| 0 2 2 5
mulr| 0 2 2 4
muli| 0 2 2 6
banr| 0 2 2 2
bani| 0 2 2 2
borr| 0 2 2 2
bori| 0 2 2 3
setr| 0 2 2 2
seti| 0 2 2 3
gtir| 0 2 2 1
gtri| 0 2 2 0
gtrr| 0 2 2 0
eqir| 0 2 2 0
eqri| 0 2 2 0
eqrr| 0 2 2 1
```
We check for which outputs match the after values, and return the keys in those positions:
```q
q)where paf~\:af
`gtri`gtrr`eqir`eqri
```
The result of the iteration of the function over the entire input:
```q
q)matches:d16match[key d16ins]'[code;before;after]
q)matches
`gtri`gtrr`eqir`eqri
`gtri`gtrr`eqir`eqri
`setr`gtir
`banr`bani`seti`gtir`gtri`gtrr`eqir`eqri`eqrr
..
```
We count each element in the list and find which are 3 or greater:
```q
q)sum 3<=count each matches
663i
```

## Part 2
We use the helper function to parse the input, then extract the needed components:
```q
q)cba:d16 x;code:cba 0;before:cba 1;after:cba 2;test:cba 3;
```
We generate a map of possibilities for each number, initially indicating that each number can mean
any instruction:
```q
q)poss:til[16]!16#enlist key d16ins
q)poss
0 | addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr
1 | addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr
2 | addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr
3 | addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr
..
```
The helper function `d16filt` filters the list of possibilities. It takes the current possibility
map and a single experiment:
```q
q)cba:(first code;first before;first after)
```
We fetch the instruction number from the code:
```q
q)ins:cba[0][0]
q)ins
11
```
We use the helper function from part 1 to find which instructions match:
```q
q)match:d16match[poss ins;cba 0;cba 1;cba 2]
q)match
`gtri`gtrr`eqir`eqri
```
We update the possibility map by taking the intersection of the existing possibilities with those
found by the experiment:
```q
q)poss[ins]:poss[ins]inter match
q)poss
0 | `addr`addi`mulr`muli`banr`bani`borr`bori`setr`seti`gtir`gtri`gtrr`eqir`eqri`eqrr
1 | `addr`addi`mulr`muli`banr`bani`borr`bori`setr`seti`gtir`gtri`gtrr`eqir`eqri`eqrr
...
10| `addr`addi`mulr`muli`banr`bani`borr`bori`setr`seti`gtir`gtri`gtrr`eqir`eqri`eqrr
11| `gtri`gtrr`eqir`eqri
12| `addr`addi`mulr`muli`banr`bani`borr`bori`setr`seti`gtir`gtri`gtrr`eqir`eqri`eqrr
..
```
If the current instruction only has one possibility, we remove this possibility from every other
instruction:
```q
    if[1=count poss[ins]; poss[til[16]except ins]:poss[til[16]except ins] except\:poss[ins][0]]
```
The return value is the updated `poss` map.

We call this helper function iterated with `/` (over), starting with the full possibility map and
passing in 3-tuples from the lists in turn:
```q
q)poss2:d16filt/[poss;(;;)'[code;before;after]]
q)poss2
0 | mulr
1 | addr
2 | banr
3 | eqir
4 | muli
5 | setr
6 | eqri
7 | gtri
8 | eqrr
9 | addi
10| gtir
11| gtrr
12| borr
13| bani
14| seti
15| bori
```
In a well-formed input, each item in the map will be a one-element list, so we take the first of
each element:
```q
q)insmap:first each poss2
q)insmap
0 | mulr
1 | addr
2 | banr
3 | eqir
4 | muli
5 | setr
6 | eqri
7 | gtri
8 | eqrr
9 | addi
10| gtir
11| gtrr
12| borr
13| bani
14| seti
15| bori
```
With the instruction map in hand, we iterate over the test program using `/` (over), passing in the
all-zero register map as the initial value and iterating over the test program:
```q
q){[insmap;r;c]d16ins[insmap c 0][c;r]}[insmap]/[0 0 0 0;test]
525 3 0 525
```
The answer is the first element of the result:
```q
q)first {[insmap;r;c]d16ins[insmap c 0][c;r]}[insmap]/[0 0 0 0;test]
525
```
