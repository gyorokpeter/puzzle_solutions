# Breakdown

## Common
The intcode interpreter is based on the on the one for [day 5](day5.md). This could be used as is
for part 1, but part 2 a new feature is needed to be able to run multiple instances in parallel.
In particular whenever an instance tries to read past the end of the input tape, it should block and
"yield" to allow more input to arrive. This blocking is implemented by changing the interpretation
of both the input and output of the `intcode` function.

In the `IN` instruction handler, if there is no available input, it immediately returns with a
general list with ``` `pause``` as its first element and the virtual machine state in the other
elements (instruction pointer, tape pointer, input tape, the contents of the memory and the output):
```q
      op=3;[$[tp>=count input; :(`pause;ip;0;a;0#input;output);
        [a[argv0 0]:input[tp]; tp+:1; ip+:1+argc]]];
```
I took the opportunity to cut the input tape to empty since we will never pause with non-empty input
for now.

When such a suspended state is passed in as the first parameter to `intcode`, the state is resumed
(thus executing the last input instruction again) instead of starting with a fresh state:
```q
    output:();
    $[a[0]~`pause;
        [ip:a[1];tp:a[2];input:a[4],input;a:a[3]];
        [ip:0;tp:0]
    ];
```
Since there is no global state, it is possible to keep a list of multiple suspended states without
the risk of state sharing between multiple instances.

Another common function is generating the permutations of a list:
```q
    perms:{$[0=count x;enlist x;raze x,/:'.z.s each x except/:x]};
```
This means for every element, generate all the permutations of the remaining elements and then
prepend the skipped element to the beginning of each. For an empty list we return an empty list
of permutations.

## Part 1
Example input:
```q
x:enlist"3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"
```
We parse the input as usual for intcode puzzles:
```q
q)a:"J"$","vs raze x
q)a
3 15 3 16 1002 16 10 16 1 16 15 15 4 15 99 0 0
```
We generate the permutations of the numbers from 0 to 4:
```q
q)p:perms til 5
q)p
0 1 2 3 4
0 1 2 4 3
0 1 3 2 4
0 1 3 4 2
0 1 4 2 3
..
```
To calculate the outputs for a given permutation, we use a function iterated with `/` (over). The
core of the iterated function is a call to `intcode`:
```q
    intcode[a;id,signal]
```
To make it possible to pass the result to the next iteration, we use a parameter `ir` which is a
pair of the current signal strength and the list of remaining amplifier IDs. Substituting this, the
call to `intcode` looks like:
```q
    intcode[a;(first ir[1]),ir[0]]
```
The output value of `ir` is the first (and only) output number plus the list of IDs with the first
element removed:
```q
    (first intcode[a;(first ir[1]),ir[0]];1_ir 1)
```
We also need a base case to end the iteration. The condition will be when no IDs are left, and in
this case we just return `ir` unchanged.
```q
    $[0=count ir 1;ir;(first intcode[a;(first ir[1]),ir[0]];1_ir 1)]
```
Since we need access to `a`, it needs to be passed in as a parameter, but we can project the
function with this value as it doesn't change.
```q
    {[a;ir]$[0=count ir 1;ir;(first intcode[a;(first ir[1]),ir[0]];1_ir 1)]}[a]
```
We call this function iterated with `/` (over) on each permutation:
```q
q){[a;ir]$[0=count ir 1;ir;(first intcode[a;(first ir[1]),ir[0]];1_ir 1)]}[a]/'[p2]
1234 `long$()
1243 `long$()
1324 `long$()
1342 `long$()
..
```
The depleted ID lists are no longer useful so we take the first element of each result:
```q
q)rs:first each{[a;ir]$[0=count ir 1;ir;(first intcode[a;(first ir[1]),ir[0]];1_ir 1)]}[a]/'[p2]
q)rs
1234 1243 1324 1342 1423 1432 2134 2143 2314 2341 2413 2431 3124 3142 3214 3241 3412 3421 4123 413..
```
The answer is the maximum of these numbers:
```q
q)max rs
43210
```

## Part 2
Example input:
```q
x:"3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,"
x,:"27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"
```
We generate the permutations of the correct IDs:
```q
q)ps:perms 5+til 5
q)ps
5 6 7 8 9
5 6 7 9 8
5 6 8 7 9
5 6 8 9 7
..
```
We initialize an array of states with 5 copies of the program:
```q
q)s:5#enlist a
q)s
3 15 3 16 1002 16 10 16 1 16 15 15 4 15 99 0 0
3 15 3 16 1002 16 10 16 1 16 15 15 4 15 99 0 0
3 15 3 16 1002 16 10 16 1 16 15 15 4 15 99 0 0
3 15 3 16 1002 16 10 16 1 16 15 15 4 15 99 0 0
3 15 3 16 1002 16 10 16 1 16 15 15 4 15 99 0 0
```
The core of the solution is another iterated function. This takes a tuple of 
`(state;index;permutation;signal)`. The index rotates from 0 to 4 and back. The permutation is only
used on the first round for initialization, otherwise the previous state is resumed.

A bare integer will be used to indicate the end of the iteration. So if the count of the parameter
is 1, we quit early:
```q
    if[1=count x;:x];
```
Otherwise, we unpack the parameter:
```q
    s:x 0;i:x 1;p:x 2;f:x 3;
```
The main point of the function is calling `intcode`. The input and output state is `s[i]`. For the
input, we prepend the first element of the permutation if any, otherwise we prepend an empty list.
In either case, the input includes the frequency.
```q
    s[i]:intcode[s[i];$[0<count p;1#p;()],f]
```
We extract the new frequency, which is the first (and only) element of the output, which is the last
element of the paused state. (When the VM halts and only returns a list, doing the `first` and
`last` like this still has the correct result.)
```q
    f:first last s[i]
```
We drop the first element of the permutation. This does nothing if the list is already empty.
```q
    p:1_p
```
We increase the index, rolling over at 5:
```q
    i:(1+i)mod 5
```
We return the special case for the finished simulation if the current state is not paused and we are
at the last amplifier (in which case the index has just rolled over to 0):
```q
    if[(i=0) and not`pause~first s[4]; :f]
```
Otherwise we return the new parameter for the iterated function:
```q
    (s;i;p;f)
```
The initial value of the parameter is `(s;0;p;0)` where `p` is the permutation. To make it easier to
iterate, we wrap the function in a second layer which only takes the state and permutation:
```q
    run:{{[x]
        ...
   }/[(x;0;y;0)]};
```
We then call this with `s` fixed as the first parameter and iterating over the `ps` list:
```q
q)rs:run[s]each ps
q)rs
61696857 62779258 63861659 66026461 67108862 68191263 66026461 67108862 70356065 73603268 73603268..
```
As with part 1, the answer is the maximum of the results.
```q
q)max rs
139629729
```

## Whiteboxing
Example input:
```q
q)md5 raze x
0x5e3f8b61a297956ae0e787075ccef521
```
Because the inputs are copyrighted, I cannot include them in this breakdown.

### Part 1
When the program starts, it reads in the "phase setting" which is actually an index into a jump
table that starts at address `10` and contains 10 addresses (5 for part 1 and 5 for part 2).
At each destination there is a small program that first inputs a value, then does some `ADD`/`MUL`
instructions between the number and small constants (2, 3, 4, 5) and outputs the result.

First we get the jump table:
```q
q)jmptbl:10#10_a
q)jmptbl
21 38 63 72 85 110 191 272 353 434
```
Then we get the first 5 programs by cutting the code on these indices, reversing them and trimming
off the beginning and ending housekeeping code, and dropping the 9's in the arguments such that
only the useful argument remains:
```q
q)prgs:reverse each 2 cut/:(-3_/:2_/:5#jmptbl cut a)except\:9
q)prgs
(102 3;101 2;102 4)
(101 3;1002 5;1001 5;102 2;1001 4)
,1001 2
(102 2;1001 3)
(101 2;1002 4;1001 2;102 2;101 2)
```
Then we assign either `+` or `*` depending on the last digit of the instruction:
```q
q)oper:(::;+;*)prgs[;;0]mod 10
q)oper
(*;+;*)
(+;*;+;*;+)
,+
(*;+)
(+;*;+;*;+)
```
We extract the numeric arguments:
```q
q)arg:prgs[;;1]
q)arg
3 2 4
3 5 5 2 4
,2
2 3
2 4 2 2 2
```
We use q's [function composition](https://code.kx.com/q/ref/compose/) operator with the `/` (over)
iterator to marry the operators with the fixed operands, so each line becomes an actual invokable q
object that calculates the respective function:
```q
q)fns:{('[;])/[x]}each oper@''arg
q)fns
*[3]+[2]*[4]
+[3]*[5]+[5]*[2]+[4]
+[2]
*[2]+[3]
+[2]*[4]+[2]*[2]+[2]
```
(This is why the reverse was needed: the function returned by the composition operator applies the
first function on the result of the second, the opposite order we find them.) We get the
permutations as usual:
```q
q)p:perms til 5
```
But instead of running the intcode VM, we simply use our precomposed functions on each permutation
and take the maximum. Note that the `/` iterator is used to chain the functions, and the body is the
function `{y x}` since we have a list of functions which is a bit unusual.
```q
q)max {{y x}/[0;x]}each fns p
17790
```

### Part 2
The program still uses the same lookup table, now using indices 5 to 9 to choose where to jump. This
time each program has 10 sequences of input-process-output instructions, follwed by a halt. The
processing instruction is always either add 1 or 2, or multiply by 2. So overall each amplifier
reads 10 inputs before halting. We get the 5 programs used for part 2, remove the final `HLT`
instruction, and cut each program into 8 numbers (the length of each processing sequence):
```q
q)jmptbl:10#10_a
q)prgs:8 cut/:-1_/:-5#jmptbl cut a
q)prgs
3 9 1002 9 2 9 4 9 3 9 102  2 9 9 4 9 3 9 101  2 9 9 4 9 3 9 101  2 9 9 4 9 3..
3 9 1001 9 1 9 4 9 3 9 102  2 9 9 4 9 3 9 1001 9 2 9 4 9 3 9 102  2 9 9 4 9 3..
3 9 1001 9 1 9 4 9 3 9 1001 9 1 9 4 9 3 9 1001 9 2 9 4 9 3 9 102  2 9 9 4 9 3..
3 9 1001 9 2 9 4 9 3 9 1002 9 2 9 4 9 3 9 101  1 9 9 4 9 3 9 102  2 9 9 4 9 3..
3 9 1002 9 2 9 4 9 3 9 101  1 9 9 4 9 3 9 101  2 9 9 4 9 3 9 101  1 9 9 4 9 3..
```
We figure out the operator by looking at index 2 in each small piece:
```q
q)oper:(::;+;*)prgs[;;2]mod 10
q)oper
* * + + + + * + + *
+ * + * + + * + + +
+ + + * * * * * + +
+ * + * + * * + * *
* + + + + * + * * +
```
We find the numeric arguments - they are at index 3 or 4, and they are not 9:
```q
q)arg:raze each (2#/:/:3_/:/:prgs)except\:\:9
q)arg
2 2 2 2 1 2 2 2 1 2
1 2 2 2 2 2 2 2 2 1
1 1 2 2 2 2 2 2 2 2
2 2 1 2 2 2 2 2 2 2
2 1 2 1 2 2 2 2 2 2
```
Like in part 1 we marry the operators with the operands, creating projections, however this time we
don't compose them:
```q
q)fns:oper@''arg
q)fns
*[2] *[2] +[2] +[2] +[1] +[2] *[2] +[2] +[1] *[2]
+[1] *[2] +[2] *[2] +[2] +[2] *[2] +[2] +[2] +[1]
+[1] +[1] +[2] *[2] *[2] *[2] *[2] *[2] +[2] +[2]
+[2] *[2] +[1] *[2] +[2] *[2] *[2] +[2] *[2] *[2]
*[2] +[1] +[2] +[1] +[2] *[2] +[2] *[2] *[2] +[2]
```
To execute these in the correct order, we need to go in columns from left to right. This means we
have to flip and raze this matrix, then the operations will be in the right order. However we need
the permutations first:
```q
q)p:perms til 5
```
We still permute the numbers of 0 to 4 as in part 1, not from 5 to 9 as in the blackbox solution.
The number offset of 5 is no longer relevant at this point. Finally we iteratively apply the flipped
and razed function list with a starting value of 0 on each permutation and take the maximum:
```q
q)max {[fns;x]{y x}/[0;raze flip fns x]}[fns]each p
19384820
```
