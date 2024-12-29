# Breakdown

Example input:
```q
x:();
x,:enlist"............";
x,:enlist"........0...";
x,:enlist".....0......";
x,:enlist".......0....";
x,:enlist"....0.......";
x,:enlist"......A.....";
x,:enlist"............";
x,:enlist"............";
x,:enlist"........A...";
x,:enlist".........A..";
x,:enlist"............";
x,:enlist"............";
```

## Part 1
We cache the width and height of the map:
```q
q)h:count x; w:count x 0
q)h
12
q)w
12
```
We find the coordinates of all the emitters. The [2D search](../utils/patterns.md#2d-search)
technique can be used to find one specific character, but now we would like to find all of them.
This can be done using the [`group`](https://code.kx.com/q/ref/group/) function, which essentially
does the search for every distinct element of a list. It still only returns the second coordinate so
we have to concatenate the row index.
```q
q)group each x
(,".")!,0 1 2 3 4 5 6 7 8 9 10 11
".0"!(0 1 2 3 4 5 6 7 9 10 11;,8)
".0"!(0 1 2 3 4 6 7 8 9 10 11;,5)
".0"!(0 1 2 3 4 5 6 8 9 10 11;,7)
".0"!(0 1 2 3 5 6 7 8 9 10 11;,4)
".A"!(0 1 2 3 4 5 7 8 9 10 11;,6)
(,".")!,0 1 2 3 4 5 6 7 8 9 10 11
(,".")!,0 1 2 3 4 5 6 7 8 9 10 11
".A"!(0 1 2 3 4 5 6 7 9 10 11;,8)
".A"!(0 1 2 3 4 5 6 7 8 10 11;,9)
(,".")!,0 1 2 3 4 5 6 7 8 9 10 11
(,".")!,0 1 2 3 4 5 6 7 8 9 10 11
q)til[h],/:/:'group each x
(,".")!,(0 0;0 1;0 2;0 3;0 4;0 5;0 6;0 7;0 8;0 9;0 10;0 11)
".0"!((1 0;1 1;1 2;1 3;1 4;1 5;1 6;1 7;1 9;1 10;1 11);,1 8)
".0"!((2 0;2 1;2 2;2 3;2 4;2 6;2 7;2 8;2 9;2 10;2 11);,2 5)
".0"!((3 0;3 1;3 2;3 3;3 4;3 5;3 6;3 8;3 9;3 10;3 11);,3 7)
".0"!((4 0;4 1;4 2;4 3;4 5;4 6;4 7;4 8;4 9;4 10;4 11);,4 4)
".A"!((5 0;5 1;5 2;5 3;5 4;5 5;5 7;5 8;5 9;5 10;5 11);,5 6)
(,".")!,(6 0;6 1;6 2;6 3;6 4;6 5;6 6;6 7;6 8;6 9;6 10;6 11)
(,".")!,(7 0;7 1;7 2;7 3;7 4;7 5;7 6;7 7;7 8;7 9;7 10;7 11)
".A"!((8 0;8 1;8 2;8 3;8 4;8 5;8 6;8 7;8 9;8 10;8 11);,8 8)
".A"!((9 0;9 1;9 2;9 3;9 4;9 5;9 6;9 7;9 8;9 10;9 11);,9 9)
(,".")!,(10 0;10 1;10 2;10 3;10 4;10 5;10 6;10 7;10 8;10 9;10 10;10 11)
(,".")!,(11 0;11 1;11 2;11 3;11 4;11 5;11 6;11 7;11 8;11 9;11 10;11 11)
```
To combine the results, we need to iterate pairwise concatenation, which means using `,'` with `/`
(over). However, just doing this to the output would result in garbage, since any missing elements
(such as the `"0"` element for the first list) are filled in with the skeleton of the first element,
which in this case would be lots of empty `long` lists. We can avoid this by prepending a dummy
element, such as mapping the `" "` character to an empty general list:
```q
q)(enlist[" "]!enlist()),/:til[h],/:/:'group each x
" ."!(();(0 0;0 1;0 2;0 3;0 4;0 5;0 6;0 7;0 8;0 9;0 10;0 11))
" .0"!(();(1 0;1 1;1 2;1 3;1 4;1 5;1 6;1 7;1 9;1 10;1 11);,1 8)
" .0"!(();(2 0;2 1;2 2;2 3;2 4;2 6;2 7;2 8;2 9;2 10;2 11);,2 5)
" .0"!(();(3 0;3 1;3 2;3 3;3 4;3 5;3 6;3 8;3 9;3 10;3 11);,3 7)
" .0"!(();(4 0;4 1;4 2;4 3;4 5;4 6;4 7;4 8;4 9;4 10;4 11);,4 4)
" .A"!(();(5 0;5 1;5 2;5 3;5 4;5 5;5 7;5 8;5 9;5 10;5 11);,5 6)
" ."!(();(6 0;6 1;6 2;6 3;6 4;6 5;6 6;6 7;6 8;6 9;6 10;6 11))
" ."!(();(7 0;7 1;7 2;7 3;7 4;7 5;7 6;7 7;7 8;7 9;7 10;7 11))
" .A"!(();(8 0;8 1;8 2;8 3;8 4;8 5;8 6;8 7;8 9;8 10;8 11);,8 8)
" .A"!(();(9 0;9 1;9 2;9 3;9 4;9 5;9 6;9 7;9 8;9 10;9 11);,9 9)
" ."!(();(10 0;10 1;10 2;10 3;10 4;10 5;10 6;10 7;10 8;10 9;10 10;10 11))
" ."!(();(11 0;11 1;11 2;11 3;11 4;11 5;11 6;11 7;11 8;11 9;11 10;11 11))
q)(,')/[(enlist[" "]!enlist()),/:til[h],/:/:'group each x]
 | ()
.| (0 0;0 1;0 2;0 3;0 4;0 5;0 6;0 7;0 8;0 9;0 10;0 11;1 0;1 1;1 2;1 3;1 4;1 5;1 6;1 7;1 9;1 10;1 1..
0| (1 8;2 5;3 7;4 4)
A| (5 6;8 8;9 9)
```
We remove the garbage empty and dot elements:
```q
q)a:" ."_(,')/[(enlist[" "]!enlist()),/:til[h],/:/:'group each x]
q)a
0| (1 8;2 5;3 7;4 4)
A| (5 6;8 8;9 9)
```
Next we calculate the positions of the anti-nodes by executing a function pairwise between two
copies of the list of coordinates. The argument is a dictionary and we need to
calculate the coordinates within each signal type, we have to use `each`:
```q
b:{...}each a
```
The function to apply between the coordinates will need to pair up the list with itself in all
combinations, which can be done by using both _each-left_ and _each-right_:
```q
b:{x{...}/:\:x}each a
```
The inner lambda is the actual calculation. We compare the two parameters to see if we are trying to
pair a coordinate with itself. In that case we return an empty list:
```q
$[x~y;();...]
```
Otherwise we return a one-element list with the coordinates of the anti-node, which we obtain by
adding the difference between the second and the first argument to the second argument.
```q
$[x~y;();enlist y+y-x]
```
Note that because the pairing up also means the function will be called with the arguments reversed,
we only need to calculate one anti-node for each pair and this will correctly generate all of them.
```q
q)b:{x{$[x~y;();enlist y+y-x]}/:\:x}each a
q)b
0| ((();,3 2;,5 6;,7 0);(,0 11;();,4 9;,6 3);(,-1 9;,1 3;();,5 1);(,-2 12;,0 6;,2 10;()))
A| ((();,11 10;,13 12);(,2 4;();,10 10);(,1 3;,7 7;()))
```
The choice of making every element either a 0- or 1-element list is only to make it easy to raze
all the results into lists:
```q
q)c:raze raze raze b
q)c
3  2
5  6
7  0
0  11
4  9
6  3
..
```
To find the number of antinodes, we filter the list to coordinates in bounds of the map and take
the distinct elements of the filtered list:
```q
q)c within\:(0 0;(h-1;w-1))
11b
11b
11b
11b
11b
11b
01b
..
q)all each c within\:(0 0;(h-1;w-1))
111111011011101111b
q)c where all each c within\:(0 0;(h-1;w-1))
3  2
5  6
7  0
0  11
4  9
..
q)count c where all each c within\:(0 0;(h-1;w-1))
15
q)count distinct c where all each c within\:(0 0;(h-1;w-1))
14
```

## Part 2
The code for part 1 looks like this so far:
```q
d8p1:{h:count x; w:count x 0;
    a:" ."_(,')/[(enlist[" "]!enlist()),/:til[h],/:/:'group each x];
    b:{x{$[x~y;();enlist y+y-x]}/:\:x}each a;
    c:raze raze raze b;
    count distinct c where all each c within\:(0 0;(h-1;w-1))};
```
This lends itself to generalization: we only need to turn the logic `enlist y+y-x` into a parameter.
However due to the use of nested lambdas, the parameter needs to be added to the parameter list of
every lambda to be passed down the call chain.
```q
d8:{[f;x]h:count x; w:count x 0;
    a:" ."_(,')/[(enlist[" "]!enlist()),/:til[h],/:/:'group each x];
    b:{[f;x]x{[f;x;y]$[x~y;();f[x;y]]}[f]/:\:x}[f]each a;
    c:raze raze raze b;
    count distinct c where all each c within\:(0 0;(h-1;w-1))};
d8p1:{d8[{enlist y+y-x};x]};
```
For the logic of part 2, we need to generate antinodes in a straight line, by repeating the addition
until we reach the edge of the map. There is a version of `/` (over) that takes a boolean predicate
telling it whether it should continue iterating. We could write the predicate as
`{all x within (0 0;(h-1;w-1))`, however there is a way to avoid making a lambda for this.
We can project `within` with its second parameter fixed:
```q
within[;(0 0;(h-1;w-1))]
```
And we can add the `all` function call at the beginning using a rare use of `'`:
[composition](https://code.kx.com/q/ref/compose/).
```q
'[all;within[;(0 0;(h-1;w-1))]]
```
Given two pairs of coordinates, `x` and `y`, we would like to start from `y` and keep adding `y-x`
until the above predicate returns false. So the function we are iterating is `(y-x)+` (we project
the left argument of `+` with the value `y-x`), and we use `\` (scan) so we can keep all the
intermediate values:
```q
((y-x)+)\['[all;within[;(0 0;(h-1;w-1))]];y]
```
Conveniently, this will include `y` itself in the result, as well as all antinodes until the edge of
the map. Just like with part 1, we don't have to worry about the other direction, as the pairing of
coordinates will ensure that the function will be called with the values of `x` and `y` swapped.

In order to use the above function as the `f` parameter to `d8`, we need to precalculate `w` and `h`
and bind them to the lambda:
```q
q)h:count x; w:count x 0
q)f:{[h;w;x;y]((y-x)+)\['[all;within[;(0 0;(h-1;w-1))]];y]}[h;w]
q)d8[f;x]
34
```
