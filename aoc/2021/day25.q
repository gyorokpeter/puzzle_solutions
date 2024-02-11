d25:{
    a:{?[;;" "]'[x<>".";x]}"\n"vs x;
    a:{a:x[0];i:x[1];
        a0:a;
        move:(a=">")and" "=1 rotate/:a;
        a:?[;;" "]'[not move;a]^?[;">";" "]'[-1 rotate/:move];
        move:(a="v")and" "=1 rotate a;
        a:?[;;" "]'[not move;a]^?[;"v";" "]'[-1 rotate move];
        (a;$[a~a0;i;i+1])}/[(a;1)];
    last a};

/
x:"v...>>.vv>\n.vv>>.vv..\n>>.>v>...v\n>>v>>.>.v.\nv>v.vv.v..\n>.>>..v...\n.vv.";
x,:".>.>v.\nv.v..>>v.v\n....v..v.>";
d25 x

OVERVIEW:
We use an iterated function that stops after there is no change. Unfortunately there is no overload
of / that stops when the state no longer changes and also returns the number of iterations. A
workaround could be to use \ and count the number of states, but that would also store each state
of the grid in memory so it would be inefficient. Another workaround would be to use a global
variable for the state count but I'm avoiding that for clean code reasons. So the iterated function
has the grid and the current step number as the state, and uses an if-then-else to not increment
the state number if the state didn't change.
The updating of the state is done by a combination of rotation and boolean arithmetic. There is no
need to pad the grid since the wraparound behavior is exactly what we want. Then the grid changes
are implemented using vector conditional, which is useful for substituting a value based on a
boolean vector. Note that we also change the "empty" marker from "." to " " because the space
counts as null for characters so we can use ^ (fill) to overlay one array on another and keep the
values that "show through".
