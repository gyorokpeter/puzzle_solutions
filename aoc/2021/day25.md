# Breakdown
Example input:
```q
x:"v...>>.vv>\n.vv>>.vv..\n>>.>v>...v\n>>v>>.>.v.\nv>v.vv.v..\n>.>>..v...\n.vv.";
x,:".>.>v.\nv.v..>>v.v\n....v..v.>";
```
We cut the input into lines and replace the empty space marker with the actual space character.
This is useful because the space counts as null for characters so we can use `^` (fill) to overlay
one array on another and keep the values that "show through".
```q
q)a:{?[;;" "]'[x<>".";x]}"\n"vs x
q)a
"v   >> vv>"
" vv>> vv  "
">> >v>   v"
">>v>> > v "
"v>v vv v  "
"> >>  v   "
" vv  > >v "
"v v  >>v v"
"    v  v >"
```
We use an iterated function that stops after there is no change. Unfortunately there is no overload
of / that stops when the state no longer changes and also returns the number of iterations. A
workaround could be to use \ and count the number of states, but that would also store each state
of the grid in memory so it would be inefficient. Another workaround would be to use a global
variable for the state count but I'm avoiding that for clean code reasons. So the iterated function
has the grid and the current step number as the state, and uses an if-then-else to not increment
the state number if the state didn't change.
```q
    a:{a:x[0];i:x[1];
        ...
    (a;$[a~a0;i;i+1])}/[(a;1)];
```
After the iteration, the last element of the pair is the answer.
```q
    last a
```
## Iteration
We save the current state to another variable so that we can check for changes at the end:
```q
q)a0:a
```
The updating of the state is done by a combination of rotation and boolean arithmetic. There is no
need to pad the grid since the wraparound behavior is exactly what we want. Then the grid changes
are implemented using vector conditional, which is useful for substituting a value based on a
boolean vector.
```q
q)move:(a=">")and" "=1 rotate/:a
q)move
0000010000b
0000100000b
0100010000b
0000101000b
0000000000b
1001000000b
0000010000b
0000000000b
0000000001b
q)a:?[;;" "]'[not move;a]^?[;">";" "]'[-1 rotate/:move]
q)a
"v   > >vv>"
" vv> >vv  "
"> >>v >  v"
">>v> > >v "
"v>v vv v  "
" >> > v   "
" vv   >>v "
"v v  >>v v"
">   v  v  "
q)move:(a="v")and" "=1 rotate a
q)move
1000000010b
0100000100b
0000100001b
0000000010b
1000010100b
0000000000b
0100000010b
0010000001b
0000000000b
q)a:?[;;" "]'[not move;a]^?[;"v";" "]'[-1 rotate move]
q)a
"    > >v >"
"v v> >v v "
">v>>  >v  "
">>v>v> > v"
" >v v   v "
"v>> >vvv  "
"  v   >>  "
"vv   >>vv "
"> v v  v v"
```
The result of the iteration step is the updated map and the step count. We don't increase the step
count if there was no change in the map.
```q
    (a;$[a~a0;i;i+1])
```
