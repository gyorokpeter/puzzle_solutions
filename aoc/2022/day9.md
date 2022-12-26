# Breakdown
Example input:
```q
x:"\n"vs"R 4\nU 4\nL 3\nD 1\nR 4\nD 1\nL 5\nR 2";
```

## Common
Both parts can be solved using the same algorithm, with only the number of rope sections (besides the head) being the parameter.

We split the input lines on spaces:
```q
q)a:" "vs/:x;
q)a
,"R" ,"4"
,"U" ,"4"
,"L" ,"3"
,"D" ,"1"
,"R" ,"4"
,"D" ,"1"
,"L" ,"5"
,"R" ,"2"
```
We retrieve the directions from the first elements, and the amounts from the second elements (converting to integer):
```q
q)dir
"RULDRDLR"
q)amt:"J"$a[;1];
q)amt
4 4 3 1 4 1 5 2
```
The `where` function can be used to repeat indices by passing in the repetition amounts. We can use this to duplicate the directions the necessary amount of times.
```q
q)where amt
0 0 0 0 1 1 1 1 2 2 2 3 4 4 4 4 5 6 6 6 6 6 7 7
q)dir2:dir where amt
q)dir2
"RRRRUUUULLLDRRRRDLLLLLRR"
```
We map the directions to movement deltas using a dictionary:
```q
q)mH:("UDLR"!(0 -1;0 1;-1 0;1 0))dir2;
q)mH
1  0
1  0
1  0
1  0
0  -1
0  -1
..
```
We generate all the positions of the head by taking the partial sums of the movement deltas:
```q
q)pH
0 0
1 0
2 0
3 0
4 0
4 -1
4 -2
..
```
To find the position of the tail, we will use an iterative function. We start from position `0 0` and whenever the current position is not adjacent to the position of the head, we update it accordingly. If the head position is `y` and the tail position is `x`, let's call the movement vector `d`:
```q
d:y-x
```
The tail is disconnected if there is at least one coordinate in `d` which is at least 2:
```q
1<max abs d
```
To update the position of the tail, we can only add 1 to each coordinate, in any direction. The tail will never be more than 2 units away along a single coordinate. The `signum` function can be used to clamp any non-zero value to 1, keeping the sign and any zeros. This nicely implements the priority of moving diagonally first.
```q
x+:signum d
```
Putting these together we get a stepping function:
```q
step1:{d:y-x;if[1<max abs d;x+:signum d];x};
```
To get all the tiles the tail visits, we need to iterate this with `\` _scan_, using the positions of the head as the iteration list:
```q
step:step1\[0 0;];
```
This is where the number of tail segments come in. The `step` function can be iterated using `/` _over_ to get the positions of the last segment. This time we iterate based on an iteration count rather than a list.
```q
q)t:1
q)pT:step/[t;pH]
q)pT
0 0
0 0
1 0
2 0
3 0
3 0
4 -1
4 -2
..
```
The answer is the number of distinct coordinates in the positions of the tail.
```q
q)count distinct pT
13
```

## Part 1 vs Part 2
The difference is that we set `t` to 1 for Part 1 and 9 for Part 2.
