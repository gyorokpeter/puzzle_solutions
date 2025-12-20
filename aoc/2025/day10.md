# Breakdown
Example input:
```q
x:()
x,:enlist"[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
x,:enlist"[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}"
x,:enlist"[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"
```

## Part 1
We use BFS to find the minimum number of button presses. Each row is handled separately by iterating
a function over them:
```q
    a:" "vs/:x
    r:{[a0]
        ...
    }each a

q)a0:a 0
q)a0
"[######]"
"(0,1,3,5)"
"(0,4)"
"(0,1)"
"(1,4)"
"(1,2)"
"(1,3,4,5)"
"{21,37,18,9,8,9}"
```
To find the edges of the graph we do the DFS over, we drop the first and last element, then drop the
first and last character of each line, split on commas and convert to integers:
```q
q)edge:"J"$","vs/:1_/:-1_/:1_-1_a0
q)edge
0 1 3 5
0 4
0 1
1 4
1 2
1 3 4 5
```
We find the destination node by dropping the first and last character from the first line, then
comparing the characters to `"#"` so we have a boolean array:
```q
q)dst:"#"=1_-1_a0[0]
q)dst
111111b
```
To find the source node, we index the list `00b` with the destination node, which returns as many
zeros as there are elements in the destination. This is a shortcut to create a list of a size that
matches another list.
```q
q)src:00b dst
q)src
000000b
```
We initialize the visited array and the queue, both consisting of the source node:
```q
q)visited:enlist src
q)queue:enlist src
```
We also initialize a step counter, which is used for returning the final answer:
```q
q)step:0
```
We iterate until the queue is empty, which would indicate no way to reach the destination:
```q
        while[count queue;
            ...
        ];
        '"not found"
```
In the iteration, we first increment the step counter:
```q
q)step+:1
q)step
1
```
We expand the nodes in the queue by performing an iterated functional amend between every pair of
queue element and button. We also use `distinct` to deduplicate, and get rid of any already visited
nodes:
```q
q)nxts:(distinct raze@[;;not]/:\:[queue;edge])except visited
q)nxts
110101b
100010b
110000b
010010b
011000b
010111b
```
We check if the destination node is in the expanded nodes. If so, we return the step counter.
```q
    if[dst in nxts;:step];
```
Otherwise, we add the new nodes to the visited array and replace the contents of the queue:
```q
q)visited,:nxts
q)queue:nxts
```
The code of the iteration ends here. Eventually we reach the point where the destination is in the
queue, at which point we return the step counter.
```q
q)nxts
011101b
111111b
q)step
3
```
To find the overall answer, we call this function on each line of the input, then return the sum
of the results.
```q
q)r
2 3 2
q)sum r
7
```

## Part 2
By looking at the magnitudes of the numbers in the real input, another BFS doesn't seem feasible
because we would have to store every combination of button press counts in the visited array, which
quickly grows out of control if we need hundreds of button presses on over 10 buttons.

Instead, we interpret the input as a set of equations, with more variables than equations so there
are free-floating variables, and we must minimize the sum of all the variables. This is an
[integer linear programming](https://en.wikipedia.org/wiki/Integer_programming) problem, basically
the final boss of linear algebra. While others have used pre-existing libraries like z3 and specific
linear optimization libraries, such thing doesn't exist for q (I don't count importing one of those
premade libraries via pykx as a proper solution). So I had to code it all from scratch, which took
about 2 days for research, implementation and debugging, and I still had to use someone else's
solution as an oracle to find which cases my code was generating a wrong solution so I could fix it.

Some helper funcions are used in the solution:
* Greatest common divisor
```q
    gcd:{if[null x;'"domain"];$[x<0;.z.s[neg x;y];x=y;x;x>y;.z.s[y;x];x=0;y;.z.s[x;y mod x]]};
```
* Least common multiple
```q
    lcm:{(x*y)div gcd[x;y]};
```
* Greatest common divisor, pairwise for vectors
```q
    gcdv:{exec y from {[xy]
        xy:update x:min(x;y),y:max(x;y) from xy;
        xy:update y:y mod x from xy where 0<x;
        xy}/[([]abs x;abs y)]};
```
* Bring several fractions to a common denominator
```q
    cden:{[t]t*lcm/[last each t] div last each t};
```

The parsing of `edge` is like in part 1. The destination comes from the last element instead:
```q
q)dst:"J"$","vs 1_-1_last a0
q)dst
21 37 18 9 8 9
```
We need to convert the button effects into coefficients for the equation array. To do this, we
enumerate the integers up to the count of output values, then check which of those is in each
button's effect:
```q
q)til[count dst]in/:edge
110101b
100010b
110000b
010010b
011000b
010111b
```
We put these in descending order, flip the matrix and convert into longs. The appending of the
goal is only for debugging purposes, it is not used at this point.
```q
q)cf:`long$flip desc(til[count dst]in/:edge),'til count edge
q)cf
1 1 0 0 0 0
1 0 1 0 0 0
0 1 0 1 1 0
0 0 1 1 0 1
5 4 1 3 2 0
```
We create a tableau, using the layout used by https://www.emathhelp.net/calculators/linear-programming/simplex-method-calculator/ .
Since the initial solution is not feasible, we need to add virtual variables for each constraint and
add a new goal function to minimize these variables:
```q
q)tableau:enlist[(count[edge]#0),(count[dst]#-1),0],(-1_cf),'(`long$(til count dst)=\:til count dst),'dst
q)tableau
0 0 0 0 0 0 -1 -1 -1 -1 0
1 1 0 0 0 0 1  0  0  0  3
1 0 1 0 0 0 0  1  0  0  5
0 1 0 1 1 0 0  0  1  0  4
0 0 1 1 0 1 0  0  0  1  7
```
We need to eliminate the -1's in the goal function for the virtual variables, so we subtract the
sum of the second and further lines from the first line:
```q
q)tableau[0]+:sum 1_tableau
q)tableau
2 2 2 2 1 1 0 0 0 0 19
1 1 0 0 0 0 1 0 0 0 3
1 0 1 0 0 0 0 1 0 0 5
0 1 0 1 1 0 0 0 1 0 4
0 0 1 1 0 1 0 0 0 1 7
```
Another complication is the handling of fractions. We should avoid getting an inaccurate solution
by storing fractional numbers as floats. Instead we maintain a "divisor" column at the right of the
tableau, which starts at 1, and will be used whenever we need to divide a row of the tableau.
```q
q)t:tableau,\:1
q)t
2 2 2 2 1 1 0 0 0 0 19 1
1 1 0 0 0 0 1 0 0 0 3  1
1 0 1 0 0 0 0 1 0 0 5  1
0 1 0 1 1 0 0 0 1 0 4  1
0 0 1 1 0 1 0 0 0 1 7  1
```

### simplex
We pass the tableau as `t` into the `simplex` function.

We cache the length of the tableau:
```q
q)len:count first t
q)len
12
```
We perform an iteration with an exit condition in the middle, so the loop condition is always true:
```q
    while[1b;
        ...
    ];
```
Inside the iteration, we need to find a pivot element according to some rules that Wikipedia doesn't
explain well enough. I had to rely on third party calculators to figure out how exactly this works.

The non-basic columns are those with more than one nonzero element. Note that the RHS and divisor
columns are not eligible.
```q
q)0<>flip t
11100b
11010b
10101b
10011b
10010b
10001b
01000b
00100b
00010b
00001b
11111b
11111b
q)sum each 0<>flip t
3 3 3 3 2 2 1 1 1 1 5 5i
q)1<sum each 0<>flip t
111111000011b
q)nonBasic:(-2_1<sum each 0<>flip t),00b
q)nonBasic
111111000000b
```
We pick a pivot column where the goal function has a positive coefficient that is the maximum of
those available:
```q
q)0<t 0
111111000011b
q)nonBasic and 0<t 0
111111000000b
q)t[0]where nonBasic and 0<t 0
2 2 2 2 1 1
q)t[0]=max t[0]where nonBasic and 0<t 0
111100000000b
q)pivotCol:first where t[0]=max t[0]where nonBasic and 0<t 0
q)pivotCol
0
```
If we don't find such a column, we get a null value in `pivotCol`. This indicates that the goal
can't be optimized further, so we return the tableau:
```q
    if[null pivotCol;:t];
```
Having chosen a pivot column, we have to choose a row. To do this we calculate the ratio between the
RHS values and the coefficients in the pivot column - the goal function row is not eligible so we
add an infinite value in that position:
```q
q)t[;pivotCol]
2 1 1 0 0
q)t[;len-2]
19 3 5 4 7
q)t[;len-2]%t[;pivotCol]
9.5 3 5 0w 0w
q)ratio:0w,1_t[;len-2]%t[;pivotCol]
q)ratio
0w 3 5 0w 0w
```
Additionally, any rows with a negative value in the pivot column are not eligible:
```q
q)ratio[where 0>=t[;pivotCol]]:0w
q)ratio
0w 3 5 0w 0w
```
The pivot row is the one with the lowest ratio (this is why we indicate invalid entries with
positive infinities). The ratio should not be negative but it CAN be zero.
```q
q)pivotRow:first where ratio=min ratio
q)pivotRow
1
```
The actual pivot operation is a separate helper function.
```q
    t:simpPvt[t;pivotRow;pivotCol];

q)r:pivotRow;c:pivotCol
```
This is the end of the iteration code.

### simpPvt
This function takes `t` (the tableau), `r` (the pivot row) and `c` (the pivot column).

Once again we cache the row length:
```q
q)len:count first t
q)len
12
```
We also cache the indices of the rows that change, which is all except the pivot row:
```q
q)chg:til[count t]except r
q)chg
0 2 3 4
```
If the pivot cell contains a negative value, we negate that row:
```q
    if[t[r;c]<0;t[r]*:-1];
```
We normalize the pivot row by dividing it by the pivot element. With the row-wide divisor approach,
this simply consists of replacing the pivot row's divisor with the pivot value, which effectively
means there is a 1 in the pivot cell.
```q
    t[r;len-1]:abs t[r;c];
```
We update the other rows by adding multiples of the pivot row such that it cancels out the values
in the pivot column. The whole left and right side need to be subscripted with `til len-1` because
the divisors are *not* to be overwritten by this operation.
```q
q)t[chg;til len-1]:((t[chg]*\:t[r;c])-t[r]*/:t[chg;c])[;til len-1]
q)t
0 0  2 2 1 1 -2 0 0 0 13 1
1 1  0 0 0 0 1  0 0 0 3  1
0 -1 1 0 0 0 -1 1 0 0 2  1
0 1  0 1 1 0 0  0 1 0 4  1
0 0  1 1 0 1 0  0 0 1 7  1
```
We overwrite the divisors by multiplying with the pivot row's divisor. This cancels out the
multiplication from the previous step.
```q
    t[chg;len-1]*:t[r;c]
```
We normalize the rows by dividing each row by its greatest common divisor. This prevents the
divisors from multiplying above all bounds.
```q
    t:t div gcdv/[flip t]
```
This modified tableau is the return value of the function.

### Handling the simplex result
We store the output of `simplex`:
```q
q)tableau2:simplex[min;tableau,\:1]
q)tableau2
0  0 0 0 0  0 -1 -1 -1 -1 0 1
1  1 0 0 0  0 1  0  0  0  3 1
1  0 1 0 0  0 0  1  0  0  5 1
-1 0 0 1 1  0 -1 0  1  0  1 1
0  0 0 0 -1 1 1  -1 -1 1  1 1
```
This represents a feasible solution where all the virtual variables are non-basic, so we can assume
they are zero and drop them from the tableau:
```q
q)1_(count[edge]#/:tableau2),'-2#/:tableau2
1  1 0 0 0  0 3 1
1  0 1 0 0  0 5 1
-1 0 0 1 1  0 1 1
0  0 0 0 -1 1 1 1
```
We can now add the true goal function at the top:
```q
q)tableau3:enlist[(count[edge]#-1),0 1],1_(count[edge]#/:tableau2),'-2#/:tableau2
q)tableau3
-1 -1 -1 -1 -1 -1 0 1
1  1  0  0  0  0  3 1
1  0  1  0  0  0  5 1
-1 0  0  1  1  0  1 1
0  0  0  0  -1 1  1 1
```
We now have to perform a similar cancellation step like in the first phase. This time it's a bit
more complicated since the divisors might have diverged from 1 (not yet in this example) and also
the basic variables are not in a neat order:
```q
q)tableau4:0^tableau3 div gcdv/[flip tableau3]
q)basic:where 1=sum 0<>1_tableau4
q)basic
1 2 3 5
q)brow:1+raze where each flip 0<>1_tableau4[;basic]
q)brow
1 2 3 4
q)bcf:raze(flip 1_tableau4[;basic])except\:0
q)bcf
1 1 1 1
q)mult:abs lcm/[tableau4[0;basic],bcf]
q)mult
1
q)tableau4[0]*:mult
q)c:count[first tableau4]-1
q)c
7
q)tableau4[0;til c]+:sum(tableau4[brow]*mult div bcf)[;til c]
q)tableau4
0  0 0 0 -1 0 10 1
1  1 0 0 0  0 3  1
1  0 1 0 0  0 5  1
-1 0 0 1 1  0 1  1
0  0 0 0 -1 1 1  1
```
At this point, we might as well stop because the answer is there at the top left (10).
```q
q)first -2#first tableau4
10
```
How does this run on the other example inputs?
```q
    d10p2row:{[a0]
        edge:"J"$","vs/:1_/:-1_/:1_-1_a0;
        dst:"J"$","vs 1_-1_last a0;
        cf:`long$flip desc(til[count dst]in/:edge),'til count edge;
        tableau:enlist[(count[edge]#0),(count[dst]#-1),0],(-1_cf),'(`long$(til count dst)=\:til count dst),'dst;
        tableau[0]+:sum 1_tableau;
        tableau2:simplex[min;tableau,\:1];
        tableau3:enlist[(count[edge]#-1),0 1],1_(count[edge]#/:tableau2),'-2#/:tableau2;
        tableau4:0^tableau3 div gcdv/[flip tableau3];
        basic:where 1=sum 0<>1_tableau4;
        brow:1+raze where each flip 0<>1_tableau4[;basic];
        bcf:raze(flip 1_tableau4[;basic])except\:0;
        mult:abs lcm/[tableau4[0;basic],bcf];
        tableau4[0]*:mult;
        c:count[first tableau4]-1;
        tableau4[0;til c]+:sum(tableau4[brow]*mult div bcf)[;til c];
        first -2#first tableau4};
```
Calling this on the example input results in:
```q
q)a:" "vs/:x
q)d10p2row each a
10 12 11
```
So it looks good so far.

Unfortunately this doesn't work on the actual input.
```q
q)md5 raze x
0x13e1f72a8e094bf62e4c90fb20e8320f
```
On this input, 53 out of 200 results are incorrect.

The following case gives an incorrect result:
```q
[#...##.] (0,1,2,3,5) (0,1,5) (0,5) (0,1,3,4,5,6) (1,2,4,6) (1,6) (1,4) (0,1,2,3,4,6) (4) {50,60,30,33,55,34,29}
Expected: 81
Actual: 162
```
By following the code above, we get the following result for `tableau4`:
```q
q)tableau4
0 0 0 0  0 0 0 -3 0 162 2
0 0 0 1  1 0 0 0  0 17  1
0 0 0 2  0 0 2 1  0 44  2
0 2 0 0  0 0 0 -1 0 18  2
0 0 2 0  0 0 0 1  0 16  2
0 0 0 -2 0 0 0 -3 2 8   2
0 0 0 0  0 2 0 1  0 10  2
1 0 0 0  0 0 0 0  0 16  1
```
The mistake is that we didn't actually consider the divisor when returning the result. Note that
normalization is not enough because there may be coefficients in the goal row that are coprime with
the divisor, so we need to explicitly divide the goal value with the divisor.
```q
q)(div).-2#first tableau4
81
```
The updated code:
```q
    d10p2row:{[a0]
        edge:"J"$","vs/:1_/:-1_/:1_-1_a0;
        dst:"J"$","vs 1_-1_last a0;
        cf:`long$flip desc(til[count dst]in/:edge),'til count edge;
        tableau:enlist[(count[edge]#0),(count[dst]#-1),0],(-1_cf),'(`long$(til count dst)=\:til count dst),'dst;
        tableau[0]+:sum 1_tableau;
        tableau2:simplex[min;tableau,\:1];
        tableau3:enlist[(count[edge]#-1),0 1],1_(count[edge]#/:tableau2),'-2#/:tableau2;
        tableau4:0^tableau3 div gcdv/[flip tableau3];
        basic:where 1=sum 0<>1_tableau4;
        brow:1+raze where each flip 0<>1_tableau4[;basic];
        bcf:raze(flip 1_tableau4[;basic])except\:0;
        mult:abs lcm/[tableau4[0;basic],bcf];
        tableau4[0]*:mult;
        c:count[first tableau4]-1;
        tableau4[0;til c]+:sum(tableau4[brow]*mult div bcf)[;til c];
        (div).-2#first tableau4};
```
With this change, the number of incorrect results goes down from 53 to 28...

The following case is still incorrect:
```q
[...####.] (2,3) (1,3,4,5,7) (1,3,6) (0,1,3,5,6,7) (1,3,7) (0,1,4,5,6,7) (2,4,6,7) (1,7) (1,2,3,5) (1,2,3,4,6) {31,100,51,87,60,64,64,65}
Expected: 108
Actual: 110
```
By following the code above, we get the following result for `tableau4`:
```q
q)tableau4
0 0 0 0 0 -5 1  0 0 0 550 5
5 0 0 0 0 5  2  0 0 0 115 5
0 0 0 5 0 0  -2 0 0 0 70  5
0 0 0 0 0 -5 2  0 5 0 20  5
0 0 0 0 5 0  2  0 0 0 95  5
0 5 0 0 0 -5 -2 0 0 0 40  5
0 0 0 0 0 0  -1 0 0 5 30  5
0 0 5 0 0 5  1  0 0 0 135 5
0 0 0 0 0 0  4  5 0 0 45  5
```
The problem is that the solution is not optimal. The simplex method, as applied above, only finds
_a_ feasible solution. Most of the cases are so constrained that this also happens to be optimal.
This is one of the cases when it's not. We can fix this by calling `simplex` again, this time
minimizing the real goal function:
```q
q)tableau5:simplex[min;tableau4]
q)tableau5
0 0 0 0 0 -1 0 0 -1 0 216 2
1 0 0 0 0 2  0 0 -1 0 19  1
0 0 0 1 0 -1 0 0 1  0 18  1
0 0 0 0 0 -5 2 0 5  0 20  2
0 0 0 0 1 1  0 0 -1 0 15  1
0 1 0 0 0 -2 0 0 1  0 12  1
0 0 0 0 0 -1 0 0 1  2 16  2
0 0 2 0 0 3  0 0 -1 0 50  2
0 0 0 0 0 2  0 1 -2 0 1   1
```
We can return the correct result from this version of the tableau:
```q
q)(div).-2#first tableau5
108
```
The updated code:
```q
    d10p2row:{[a0]
        edge:"J"$","vs/:1_/:-1_/:1_-1_a0;
        dst:"J"$","vs 1_-1_last a0;
        cf:`long$flip desc(til[count dst]in/:edge),'til count edge;
        tableau:enlist[(count[edge]#0),(count[dst]#-1),0],(-1_cf),'(`long$(til count dst)=\:til count dst),'dst;
        tableau[0]+:sum 1_tableau;
        tableau2:simplex[min;tableau,\:1];
        tableau3:enlist[(count[edge]#-1),0 1],1_(count[edge]#/:tableau2),'-2#/:tableau2;
        tableau4:0^tableau3 div gcdv/[flip tableau3];
        basic:where 1=sum 0<>1_tableau4;
        brow:1+raze where each flip 0<>1_tableau4[;basic];
        bcf:raze(flip 1_tableau4[;basic])except\:0;
        mult:abs lcm/[tableau4[0;basic],bcf];
        tableau4[0]*:mult;
        c:count[first tableau4]-1;
        tableau4[0;til c]+:sum(tableau4[brow]*mult div bcf)[;til c];
        tableau5:simplex[min;tableau4];
        (div).-2#first tableau5};
```
With this change, the number of incorrect results goes down from 28 to 26...

```q
[...####.] (2,3) (1,3,4,5,7) (1,3,6) (0,1,3,5,6,7) (1,3,7) (0,1,4,5,6,7) (2,4,6,7) (1,7) (1,2,3,5) (1,2,3,4,6) {31,100,51,87,60,64,64,65}
Expected: 69
Actual: 68
```
By following the code above, we get the following result for `tableau5`:
```q
q)tableau5
0 0 -1 0 0 -1 0 137 2
0 0 0  0 1 -1 0 1   1
0 2 1  0 0 1  0 59  2
2 0 1  0 0 -1 0 13  2
0 0 0  1 0 1  0 26  1
0 0 -1 0 0 1  2 11  2
```
The problem here is that some of the variables are not integers. The simplex algorithm by itself
doesn't handle the fact that the variables need to be integers. That is handled by an add-on called
the cutting plane method. It is described at https://medium.com/@minkyunglee_5476/integer-programming-the-cutting-plane-algorithm-26bbabf04815
(also on Wikipedia but that's useless for a practical implemetation because it only has random
formulas with no numerical examples).
```q
q)t:tableau5
```

### cuttingPlane
This function is one big iteraton.

We start by caching the length of the tableau row. Note that in this case the caching must be done
_inside_ the iteration, because the tableau will grow with every iteration.
```q
q)len:count first t
q)len
9
```
We find a variable that is not an integer, therefore needs splitting. We can do this by doing a
`mod` check between the RHS value and the divisor. The goal row is not eligible.
```q
q)split:first 1+where 0<1_(mod)./:-2#/:t
q)split
2
```
If there are no non-integer variables, we are done and we return the current tableau:
```q
    if[null split;:t];
```
We generate the "Gomory cut" that needs to be added to the tableau. I don't fully understand how
this works, but from the numerical example it's obvious that it's calculated via another `mod`
operation. q's `mod` is really the modulus and not remainder like in some other languages, so it's
perfect for this job.
```q
q)gcut:{(neg(-1_x)mod last x),last x}t split
q)gcut
0 0 -1 0 0 -1 0 -1 2
```
We append the cut as a row to the tableau:
```q
q)t,:gcut
q)t
0 0 -1 0 0 -1 0 137 2
0 0 0  0 1 -1 0 1   1
0 2 1  0 0 1  0 59  2
2 0 1  0 0 -1 0 13  2
0 0 0  1 0 1  0 26  1
0 0 -1 0 0 1  2 11  2
0 0 -1 0 0 -1 0 -1  2
```
We also introduce a virtual variable for the new row by splicing it before the RHS column:
```q
q)t:((len-2)#/:t),'(((count[t]-1)#0),last gcut),'-2#/:t
q)t
0 0 -1 0 0 -1 0 0 137 2
0 0 0  0 1 -1 0 0 1   1
0 2 1  0 0 1  0 0 59  2
2 0 1  0 0 -1 0 0 13  2
0 0 0  1 0 1  0 0 26  1
0 0 -1 0 0 1  2 0 11  2
0 0 -1 0 0 -1 0 2 -1  2
```
We now have to eliminate the virtual variable using what the article calls the ["dual simplex
method"](https://medium.com/@minkyunglee_5476/linear-programming-the-dual-simplex-method-d3ab832afc50)
(it's actually just one step). The only change seems to be that the choice for the pivot row and
column is reversed:
```q
    simplexRow:{[t]
        len:count first t;
        while[1b;
            infs:where 0b,1_0>t[;len-2];
            if[0=count infs;:t];
            t:cden t;
            pivotRow:first infs where t[infs;len-2]=min t[infs;len-2];
            nonBasic:(-2_1<sum each 0<>flip t),00b;
            ratio:neg (t[0]%t[pivotRow]);
            ratio[where not[nonBasic]or 0=t pivotRow]:0w;
            pivotCol:first where ratio=min ratio;
            t:simpPvt[t;pivotRow;pivotCol];
        ];
        };
```
Applying this function to the tableau:
```q
q)t:simplexRow t
q)t
0 0 0 0 0 0  0 -1 69 1
0 0 0 0 1 -1 0 0  1  1
0 1 0 0 0 0  0 1  29 1
1 0 0 0 0 -1 0 1  6  1
0 0 0 1 0 1  0 0  26 1
0 0 0 0 0 1  1 -1 6  1
0 0 1 0 0 1  0 -2 1  1
```
In this case the cutting plane method found an integer solution in just one iteration.

We can now insert this into the `d10p2row` function:
```q
q)tableau6:cuttingPlane tableau5
q)tableau6
0 0 0 0 0 0  0 -1 69 1
0 0 0 0 1 -1 0 0  1  1
0 1 0 0 0 0  0 1  29 1
1 0 0 0 0 -1 0 1  6  1
0 0 0 1 0 1  0 0  26 1
0 0 0 0 0 1  1 -1 6  1
0 0 1 0 0 1  0 -2 1  1
q)(div).-2#first tableau6
69
```
The updated code:
```q
    d10p2row:{[a0]
        edge:"J"$","vs/:1_/:-1_/:1_-1_a0;
        dst:"J"$","vs 1_-1_last a0;
        cf:`long$flip desc(til[count dst]in/:edge),'til count edge;
        tableau:enlist[(count[edge]#0),(count[dst]#-1),0],(-1_cf),'(`long$(til count dst)=\:til count dst),'dst;
        tableau[0]+:sum 1_tableau;
        tableau2:simplex[min;tableau,\:1];
        tableau3:enlist[(count[edge]#-1),0 1],1_(count[edge]#/:tableau2),'-2#/:tableau2;
        tableau4:0^tableau3 div gcdv/[flip tableau3];
        basic:where 1=sum 0<>1_tableau4;
        brow:1+raze where each flip 0<>1_tableau4[;basic];
        bcf:raze(flip 1_tableau4[;basic])except\:0;
        mult:abs lcm/[tableau4[0;basic],bcf];
        tableau4[0]*:mult;
        c:count[first tableau4]-1;
        tableau4[0;til c]+:sum(tableau4[brow]*mult div bcf)[;til c];
        tableau5:simplex[min;tableau4];
        tableau6:cuttingPlane tableau5;
        (div).-2#first tableau6};
```
But with this change there are still 3 incorrect cases?!

The following case is still incorrect:
```q
[...####.] (2,3) (1,3,4,5,7) (1,3,6) (0,1,3,5,6,7) (1,3,7) (0,1,4,5,6,7) (2,4,6,7) (1,7) (1,2,3,5) (1,2,3,4,6) {31,100,51,87,60,64,64,65}
Expected: 76
Actual: 72
```
This is a devious one because it turned out that it's due to a step in the original simplex method
that I skipped, and I still don't know when it's OK to skip and when it's not, it's just that the
calculator showed it so I added it in.

### fixBase
This is similar to the simplex method, except there is no ratio check - we just try to eliminate a
virtual variable. The number of genuine variables is passed in as a parameter.
```q
    fixBase:{[vars;t]
        while[1b;
            pivotCol:first where 0<>vars#t[0];
            if[null pivotCol;:t];
            nonBasic:vars+where vars _1=sum each 0<>flip t;
            swapVar:first nonBasic where 0<>sum t[;pivotCol]*t[;nonBasic];
            pivotRow:first where 0<>t[;swapVar];
            t:simpPvt[t;pivotRow;pivotCol];
        ];
        };
```
Adding a call to this into `d10p2row` (sorry, I'm not going to renumber the variables after all the
struggle to make this work at all):
```q
q)tableau2
0 0 -1 0 0 0 0 0 -2 -1 -1 -1 -1 -1 0 -1 0  1
0 0 1  0 3 0 0 0 -2 -2 -2 -1 -1 5  0 1  24 3
3 0 1  0 0 0 0 0 1  1  1  -1 -1 -1 0 1  42 3
0 0 4  0 0 0 3 0 1  -2 1  2  -1 -1 0 1  48 3
0 3 -1 0 0 0 0 0 2  2  -1 1  1  -2 0 -1 18 3
0 0 -1 0 0 0 0 1 1  1  0  0  1  -2 0 0  8  1
0 0 2  3 0 0 0 0 2  -1 2  1  1  -2 0 -1 57 3
0 0 -1 0 0 0 0 0 -1 0  0  0  0  0  1 0  0  1
0 0 0  0 0 1 0 0 -1 0  0  0  0  1  0 0  5  1
q)tableau2a:fixBase[count edge;tableau2]
q)tableau2a
0 0 0 0 0 0 0 0 -1 -1 -1 -1 -1 -1 -1 -1 0  1
0 0 0 0 3 0 0 0 -3 -2 -2 -1 -1 5  1  1  24 3
3 0 0 0 0 0 0 0 0  1  1  -1 -1 -1 1  1  42 3
0 0 0 0 0 0 3 0 -3 -2 1  2  -1 -1 4  1  48 3
0 3 0 0 0 0 0 0 3  2  -1 1  1  -2 -1 -1 18 3
0 0 0 0 0 0 0 1 2  1  0  0  1  -2 -1 0  8  1
0 0 0 3 0 0 0 0 0  -1 2  1  1  -2 2  -1 57 3
0 0 1 0 0 0 0 0 1  0  0  0  0  0  -1 0  0  1
0 0 0 0 0 1 0 0 -1 0  0  0  0  1  0  0  5  1
```
Continuing from here, we get
```q
q)tableau6
0 0 0 0 0 0 0 0 76 1
0 0 0 0 1 0 0 0 8  1
1 0 0 0 0 0 0 0 14 1
0 0 0 0 0 0 1 0 16 1
0 1 0 0 0 0 0 0 6  1
0 0 0 0 0 0 0 1 8  1
0 0 0 1 0 0 0 0 19 1
0 0 1 0 0 0 0 0 0  1
0 0 0 0 0 1 0 0 5  1
q)(div).-2#first tableau6
76
```
The updated code:
```q
    d10p2row:{[a0]
        edge:"J"$","vs/:1_/:-1_/:1_-1_a0;
        dst:"J"$","vs 1_-1_last a0;
        cf:`long$flip desc(til[count dst]in/:edge),'til count edge;
        tableau:enlist[(count[edge]#0),(count[dst]#-1),0],(-1_cf),'(`long$(til count dst)=\:til count dst),'dst;
        tableau[0]+:sum 1_tableau;
        tableau2:simplex[min;tableau,\:1];
        tableau2a:fixBase[count edge;tableau2];
        tableau3:enlist[(count[edge]#-1),0 1],1_(count[edge]#/:tableau2a),'-2#/:tableau2a;
        tableau4:0^tableau3 div gcdv/[flip tableau3];
        basic:where 1=sum 0<>1_tableau4;
        brow:1+raze where each flip 0<>1_tableau4[;basic];
        bcf:raze(flip 1_tableau4[;basic])except\:0;
        mult:abs lcm/[tableau4[0;basic],bcf];
        tableau4[0]*:mult;
        c:count[first tableau4]-1;
        tableau4[0;til c]+:sum(tableau4[brow]*mult div bcf)[;til c];
        tableau5:simplex[min;tableau4];
        tableau6:cuttingPlane tableau5;
        (div).-2#first tableau6};
```
This reduces the number of incorrect cases from 3 to... 2???

The following case is still incorrect:
```q
[.##.##..#.] (3,4,5,6,7,8) (3,7) (1,4,5,6,7,8,9) (1,2,4,9) (0,1,5,7,8,9) (0,1,2,4,6,8,9) (0,1,2,3,4,5,8) (0,3) (0,2,3,4,5,6,7) (0,1,5) (0,5,9) (0,1,2,3,4,5,8,9) (3,6) {183,186,153,191,181,205,55,66,166,69}
Expected: 242
Actual: 243
```
By following the code above, we get the following result for `tableau6`:
```q
q)tableau6
0 0 1  0 0 0 0 0 0  0 0 0 0 0 -3 243 1
0 0 1  0 0 0 1 0 0  0 0 0 0 0 0  6   1
0 0 0  0 0 0 0 0 1  0 0 0 1 0 -2 21  1
0 1 5  0 0 0 0 0 2  0 0 0 0 0 -7 100 1
0 0 -3 0 0 0 0 0 -2 0 1 0 0 0 3  0   1
0 0 0  0 0 1 0 0 0  0 0 0 0 0 1  16  1
0 0 -3 0 1 0 0 0 -1 0 0 0 0 0 3  20  1
0 0 1  0 0 0 0 0 0  0 0 1 0 0 -1 11  1
0 0 0  1 0 0 0 0 -1 0 0 0 0 0 1  1   1
0 0 3  0 0 0 0 0 2  1 0 0 0 0 -3 28  1
1 0 -4 0 0 0 0 0 -1 0 0 0 0 0 6  37  1
0 0 2  0 0 0 0 1 1  0 0 0 0 0 -4 3   1
0 0 1  0 0 0 0 0 0  0 0 0 0 1 -2 1   1
```
Notice that there is a positive number in the goal row. This indicates that the solution is not
optimal. So how about just throw `simplex` at it again?
```q
q)tableau7:simplex[min;tableau6]
q)tableau7
0 0 0 0 0 0 0 0 0  0 0 0 0 -1 -1 242 1
0 0 0 0 0 0 1 0 0  0 0 0 0 -1 2  5   1
0 0 0 0 0 0 0 0 1  0 0 0 1 0  -2 21  1
0 1 0 0 0 0 0 0 2  0 0 0 0 -5 3  95  1
0 0 0 0 0 0 0 0 -2 0 1 0 0 3  -3 3   1
0 0 0 0 0 1 0 0 0  0 0 0 0 0  1  16  1
0 0 0 0 1 0 0 0 -1 0 0 0 0 3  -3 23  1
0 0 0 0 0 0 0 0 0  0 0 1 0 -1 1  10  1
0 0 0 1 0 0 0 0 -1 0 0 0 0 0  1  1   1
0 0 0 0 0 0 0 0 2  1 0 0 0 -3 3  25  1
1 0 0 0 0 0 0 0 -1 0 0 0 0 4  -2 41  1
0 0 0 0 0 0 0 1 1  0 0 0 0 -2 0  1   1
0 0 1 0 0 0 0 0 0  0 0 0 0 1  -2 1   1
q)(div).-2#first tableau7
242
```
But trying to put this into the function actually *increases* the number of failures rather than
decreasing them. Turns out that using the simplex method again can result in reintroducing
non-integer variables. So I just put the call to `simplex` into the iteration in `cuttingPlane`
instead:
```q
    cuttingPlane:{[t]
        while[1b;
            len:count first t;
            split:first 1+where 0<1_(mod)./:-2#/:t;
            if[null split;:t];
            gcut:{(neg(-1_x)mod last x),last x}t split;
            t,:gcut;
            t:((len-2)#/:t),'(((count[t]-1)#0),last gcut),'-2#/:t;
            t:simplex[min;simplexRow t];
        ];
    };
```
With this change, it finally solves all the cases correctly.
