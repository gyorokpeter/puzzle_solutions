# Breakdown
Example input:
```q
x:"\n"vs"....#\n#..#.\n#..##\n..#..\n#...."
```

## Part 1
We convert the input into a boolean matrix by comparing it to `"#"`:
```q
q)a:"#"=x
q)a
00001b
10010b
10011b
00100b
10000b
```
We initialize a history variable:
```q
q)hist:()
```
We perform an iteration that has no fixed end condition. There is a return statement in the middle.
```q
    while[1b;
        ...
    ];
```
To find the neighbors of each cell, we overlay the grid with shifted copies of itself. The shift is
done by dropping a row or column at the edge and appending another one full of zeros at the other
end.
```q
q)a1:0b,/:-1_/:a
q)a2:(1_/:a),\:0b
q)a3:(1_a),enlist(count first a)#0b
q)a4:enlist[(count first a)#0b],(-1_a)
q)a1
00000b
01001b
01001b
00010b
01000b
q)a2
00010b
00100b
00110b
01000b
00000b
q)a3
10010b
10011b
00100b
10000b
00000b
q)a4
00000b
00001b
10010b
10011b
00100b
```
The neighbor count is the sum of these four matrices:
```q
q)adj:a1+a2+a3+a4
q)adj
1 0 0 2 0
1 1 1 1 3
1 1 2 2 1
2 1 0 2 1
0 1 1 0 0
```
We generate the updated state of the grid using arithmetic operations based on the conditions of the
cellular automaton:
```q
q)a:(a*adj=1)+(not[a]*(adj>=1) and adj<=2)
q)a
1 0 0 1 0
1 1 1 1 0
1 1 1 0 1
1 1 0 1 1
0 1 1 0 0
```
We calculate the "biodiversity rating", which is just this matrix taken as a long binary number in
reverse and converted into decimal:
```q
q)n:{y+2*x}/[reverse raze a]
q)n
7200233
```
To keep history, we don't have to store the grid, only the number. So we check if the current
number is already in the history, and if so, we return it as the answer:
```q
    if[n in hist; :n];
```
Otherwise, we append the number to the history:
```q
q)hist,:n
q)hist
,7200233
```
This is the end of the code of the iteration.

Eventually we reach the point where the number is already in the history:
```q
q)count hist
85
q)n
2129920
q)n in hist
1b
q)hist?n
73
```

## Part 2
The solution function takes an extra argument `c` for the number of generations:
```q
q)c:10
```
We use a helper function `.d24.updGrid` to get the next state of the grid. This function takes a
3-dimensional matrix that is 3 grids stacked on top of each other, and returns the next state of the
middle grid:
```q
    .d24.updGrid:{[g3]
        ...
    };
```
In the function, we generate the neighbors for the middle grid using shifted grids as in part 1:
```q
    a:g3[1];
    a1:0b,/:-1_/:a;
    a2:(1_/:a),\:0b;
    a3:(1_a),enlist(count first a)#0b;
    a4:enlist[(count first a)#0b],(-1_a);
    adj:a1+a2+a3+a4;
```
We also have to make some adjustments due to the grid nesting. The top row has an extra neighbor
that is at position `[2;1]` in the upper grid:
```q
    adj[;0]+:g3[0;2;1];
```
Similarly the other edges have a corresponding additional neighbor (the addition also takse care of
the corners having both of the extra neighbors):
```q
    adj[;4]+:g3[0;2;3];
    adj[0;]+:g3[0;1;2];
    adj[4;]+:g3[0;3;2];
```
The cells around the middle cell work analogously, except here we are taking lists of cells from the
lower grid and summing them:
```q
    adj[2;1]+:sum g3[2;;0];
    adj[2;3]+:sum g3[2;;4];
    adj[1;2]+:sum g3[2;0;];
    adj[3;2]+:sum g3[2;4;];
```
We also zero out the middle cell, since that is not itself a valid cell, so it should never be
populated:
```q
    adj[2;2]:0;
```
We then check the rules of the cellular automaton just like in part 1:
```q
    a:(a and adj=1)or(not[a] and (adj>=1) and adj<=2);
    a
```
The code of the helper function ends here.

We initialize the grid stack to only consist of the initial grid, and also create an empty grid to
use as the default state when expanding upwards or downwards:
```q
q)a:"#"=x
q)empty:a<>a
q)empty
00000b
00000b
00000b
00000b
00000b
q)gs:enlist a
q)gs
00001b 10010b 10011b 00100b 10000b
```
We perform an iteration `c` times:
```q
    do[c;
        ...
    ];
```
In the iteration, we add two empty grids on either end (we need one to expand indo, and another to
act as the adjacent grid for the purpose of generating that expansion):
```q
q)gs:(2#enlist empty),gs,2#enlist empty
q)gs
00000b 00000b 00000b 00000b 00000b
00000b 00000b 00000b 00000b 00000b
00001b 10010b 10011b 00100b 10000b
00000b 00000b 00000b 00000b 00000b
00000b 00000b 00000b 00000b 00000b
```
We create 3-long slices of this expanded grid and call the helper function on them:
```q
q)3#/:til[count[gs]-2]_\:gs
00000b 00000b 00000b 00000b 00000b 00000b 00000b 00000b 00000b 00000b 00001b 10010b 10011b 00100b ..
00000b 00000b 00000b 00000b 00000b 00001b 10010b 10011b 00100b 10000b 00000b 00000b 00000b 00000b ..
00001b 10010b 10011b 00100b 10000b 00000b 00000b 00000b 00000b 00000b 00000b 00000b 00000b 00000b ..
q)gs:.d24.updGrid each 3#/:til[count[gs]-2]_\:gs
q)gs
00000b 00100b 00010b 00100b 00000b
10010b 11110b 11001b 11011b 01100b
00001b 00001b 00001b 00001b 11111b
```
We drop any grids at the start and end that consist of only zeros, to prevent the stack from growing
faster than necessary:
```q
    while[0=sum sum first gs; gs:1_gs];
    while[0=sum sum last gs; gs:-1_gs];
```
The code of the iteration ends here.

After the iteration, we have the final state of the grid stack:
```q
q)gs
00100b 01010b 00001b 01010b 00100b
00010b 00011b 00000b 00011b 00010b
10100b 01000b 00000b 01000b 10100b
01011b 00001b 00001b 00011b 01110b
10011b 00011b 00000b 00010b 01111b
01000b 01011b 01000b 00000b 00000b
01100b 10011b 00001b 11011b 11111b
11100b 11010b 10000b 01011b 10100b
00111b 00000b 10000b 10000b 10001b
01110b 10010b 10000b 11010b 00000b
11110b 10010b 10010b 11110b 00000b
```
The answer is the sum of the entire matrix (one `sum` is needed per dimension):
```q
q)sum sum sum gs
99i
```
