# Breakdown

Example input:
```q
x:"\n"vs"029A\n980A\n179A\n456A\n379A";
iter:1;
```

## Common
The two parts are solved by a common algorithm. The complication is that there are multiple ways to
move between some keys (e.g. 3 to 7 can be "<<^^" or "^^<<"), which produce sequences of identical
lengths on the second and third keypads, but not the fourth one as the cost of pressing "<" is
greater than that of pressing "^" using another keypad, so solutions that use more of the former
result in longer sequences down the line. My solution looks two steps ahead to find which sequence
results in the shortest derived sequences two keypads later, and chose this as the "de facto"
sequence for that movement, which turned out to be good enough to not have any edge cases.

### Basic keypad sequence calculation
This is the function `.d21.keypath`.

We start by precalculating all sequences for moving between each pair of keys using the next
keypad in the sequence, which is always an arrow keypad. We use the same function on the numeric
and arrow keypads. This demonstration is for the numeric one:
```q
    pad:("789";"456";"123";" 0A");
```
We find all the values on the keypad and put them in ascending order (I called it `nums` but it
works the same way for the arrows):
```q
q)nums:asc raze[pad]except" "
q)nums
`s#"0123456789A"
```
We initialize a table of empty press sequences for every pair of keys:
```q
q)p:2!([]s:nums)cross([]t:nums;press:count[nums]#enlist())
q)p
s t| press
---| -----
0 0|
0 1|
0 2|
0 3|
0 4|
..
```
We initialize the press sequence for a button going to itself with the empty string (the type
matters):
```q
s t| press
---| -----
0 0| ,""
0 1| ()
0 2| ()
0 3| ()
0 4| ()
..
```
We initialize the BFS queue with every possible starting position:
```q
q)queue:([]pos:raze til[count pad],/:\:til[count first pad];path:0N 1#raze pad)
q)queue
pos path
--------
0 0 ,"7"
0 1 ,"8"
0 2 ,"9"
1 0 ,"4"
1 1 ,"5"
1 2 ,"6"
2 0 ,"1"
2 1 ,"2"
2 2 ,"3"
3 0 ," "
3 1 ,"0"
3 2 ,"A"
```
We add a column for the key press sequence:
```q
q)queue:update press:count[i]#enlist"" from queue
q)queue
pos path press
--------------
0 0 ,"7" ""
0 1 ,"8" ""
0 2 ,"9" ""
1 0 ,"4" ""
1 1 ,"5" ""
1 2 ,"6" ""
2 0 ,"1" ""
2 1 ,"2" ""
2 2 ,"3" ""
3 0 ," " ""
3 1 ,"0" ""
3 2 ,"A" ""
```
We delete the nodes corresponding to the empty space:
```q
q)queue:delete from queue where " "=last each path
q)queue
pos path press
--------------
0 0 ,"7" ""
0 1 ,"8" ""
0 2 ,"9" ""
1 0 ,"4" ""
1 1 ,"5" ""
1 2 ,"6" ""
2 0 ,"1" ""
2 1 ,"2" ""
2 2 ,"3" ""
3 1 ,"0" ""
3 2 ,"A" ""
```
We iterate until the queue is empty:
```q
    while[count queue;
        ...
    ];
```
We expand the nodes by adding the offsets for the four cardinal directions, also filling in the
next element of the press sequence:
```q
q)nxts:raze{([]pos:x[`pos]+/:(-1 0;0 1;1 0;0 -1);path:4#enlist x`path;press:x[`press],/:"^>v<")}each queue
q)nxts
pos   path press
----------------
-1 0  ,"7" ,"^"
0  1  ,"7" ,">"
1  0  ,"7" ,"v"
0  -1 ,"7" ,"<"
-1 1  ,"8" ,"^"
0  2  ,"8" ,">"
..
```
We append the key at the new position to the path:
```q
q)nxts:update path:(path,'pad ./:pos) from nxts
q)nxts
pos   path press
----------------
-1 0  "7 " ,"^"
0  1  "78" ,">"
1  0  "74" ,"v"
0  -1 "7 " ,"<"
-1 1  "8 " ,"^"
..
```
We drop the nodes that end on blanks:
```q
q)nxts:delete from nxts where " "=last each path
q)nxts
pos path press
--------------
0 1 "78" ,">"
1 0 "74" ,"v"
0 2 "89" ,">"
1 1 "85" ,"v"
0 0 "87" ,"<"
..
```
We delete any nodes that return to a previously visited key:
```q
    nxts:delete from nxts where (count each path)<>count each distinct each path;
```
We delete any nodes where the press sequence isn't
[parted](https://code.kx.com/q/ref/set-attribute/#grouped-and-parted). There is no built-in check
for this property, so I do it by trying to apply the parted attribute and check if it throws an
exception or not. The reason for this check is to filter out paths like ">^>^" as these will become
much longer on the subsequent keypads and it's an easy gain to discard them early.
```q
    nxts:delete from nxts where 0b~/:@[`p#;;{0b}]each press
```
We delete any press sequences that contain both "^" and "v", or both "<" and ">", as these are not
the shortest path:
```q
    nxts:delete from nxts where all each"<>"in/:press;
    nxts:delete from nxts where all each"^v"in/:press;
```
We extract the current press sequences by start and end key:
```q
q)np
s t| press2
---| ------
0 2| ,"^"
0 A| ,">"
1 2| ,">"
1 4| ,"^"
2 0| ,"v"
..
```
We merge the newly found press sequences into the `p` table defined above:
```q
q)p:delete press2 from update press:(press,'press2) from p,'np where 0<count each first each press2
q)p
s t| press
---| -----
0 0| ,""
0 1| ()
0 2| ,,"^"
0 3| ()
0 4| ()
..
```
We replace the queue with the next nodes:
```q
    queue:nxts;
```
At the end of the iteration, `p` will contain all shortest press sequences between all pairs of
keys:
```q
q)p
s t| press
---| ---------------
0 0| ,""
0 1| ,"^<"
0 2| ,,"^"
0 3| ("^>";">^")
0 4| ,"^^<"
0 5| ,"^^"
0 6| ("^^>";">^^")
..
```
We create a dictionary where the key is `t` followed by `s` (the reason for the reversal will be
explained later), and the values are the sequences suffixed with "A" characters:
```q
q)exec (t,'s)!(press,\:\:"A") from p
"00"| ,,"A"
"10"| ,"^<A"
"20"| ,"^A"
"30"| ("^>A";">^A")
"40"| ,"^^<A"
"50"| ,"^^A"
"60"| ("^^>A";">^^A")
..
```
With this helper function, we can calculate the keypad sequences for both the numeric and arrow
keypads:
```q
q).d21.kpNum:.d21.keypath("789";"456";"123";" 0A");
q).d21.kpArrow:.d21.keypath(" ^A";"<v>");
q).d21.kpNum
"00"| ,,"A"
"10"| ,"^<A"
"20"| ,"^A"
"30"| ("^>A";">^A")
"40"| ,"^^<A"
..
q).d21.kpArrow
"<<"| ,,"A"
"><"| ,">>A"
"A<"| ,">>^A"
"^<"| ,">^A"
"v<"| ,">A"
..
```

### Extended keypad sequence calculation
This is the function `.d21.keypathExt`.

For demonstration, let's use `seq:.d21.kpNum`.

We define an expansion function that finds all the possible press sequences to enter a string on a
keypad. This uses the [each-prior (':) iterator](https://code.kx.com/q/ref/maps/#each-prior), which
passes in the consecutive elements of the list in reverse order. This was the reason of the reversal
when returning the result from `.d21.keypath`. Then we use `cross` with `over` to take the cross
product step by step on the lists of alternatives for each position.
```q
    f:{cross/[{.d21.kpArrow[x,y]}':["A",x]]};
```
We use this function to expand each sequence on the input keypad:
```q
q)press:f each/:seq
q)press
"00"| ,,,"A"
"10"| ,,"<Av<A>>^A"
"20"| ,,"<A>A"
"30"| (("<A>vA^A";"<Av>A^A");("vA^<A>A";"vA<^A>A"))
"40"| ,,"<AAv<A>>^A"
"50"| ,,"<AA>A"
..
```
We repeat this, generating the sequences two keypads down:
```q
q)press2:f each/:/:press
q)press2
"00"| ,,,,"A"
"10"| ,,("v<<A>>^Av<A<A>>^AvAA^<A>A";"v<<A>>^Av<A<A>>^AvAA<^A>A";"v<<A>>^A<vA<A>>^AvAA^<A>A";"v<<A..
"20"| ,,,"v<<A>>^AvA^A"
"30"| ((("v<<A>>^AvA<A^>A<A>A";"v<<A>>^AvA<A>^A<A>A");("v<<A>>^Av<A>A^A<A>A";"v<<A>>^A<vA>A^A<A>A"..
"40"| ,,("v<<A>>^AAv<A<A>>^AvAA^<A>A";"v<<A>>^AAv<A<A>>^AvAA<^A>A";"v<<A>>^AA<vA<A>>^AvAA^<A>A";"v..
..
```
We find the lengths of the sequences in this second generation:
```q
q)cs:count each/:/:/:press2
q)cs
"00"| ,,,1
"10"| ,,25 25 25 25
"20"| ,,,12
"30"| ((19 19;19 19);(19 19 19 19;19 19 19 19))
"40"| ,,26 26 26 26
"50"| ,,,13
..
"5A"| (,26 26 26 26;,22 22 22 22)
..
"8A"| (,27 27 27 27;,23 23 23 23)
..
```
Whenever there are multiple choices with different lengths, we would like to use the shortest one.
So we find the minima lengths:
```q
q)cs2:min each/:min each/:cs
q)cs2
"00"| ,1
"10"| ,25
"20"| ,12
"30"| 19 19
"40"| ,26
..
"5A"| 26 22
..
"8A"| 27 23
..
```
We filter the original keypad to the sequences where the second-generation length is minimal:
```q
q)seq@'first each where each cs2=min each cs2
"00"| ,"A"
"10"| "^<A"
"20"| "^A"
"30"| "^>A"
"40"| "^^<A"
..
"5A"| "<^^A"
..
"8A"| "<^^^A"
..
```
We apply this function to both keypads to generate the best sequences:
```q
q).d21.kpNumExt:.d21.keypathExt[.d21.kpNum];
q).d21.kpArrowExt:.d21.keypathExt[.d21.kpArrow];
q).d21.kpNumExt
"00"| ,"A"
"10"| "^<A"
"20"| "^A"
"30"| "^>A"
"40"| "^^<A"
..
q).d21.kpArrowExt
"<<"| ,"A"
"><"| ">>A"
"A<"| ">>^A"
"^<"| ">^A"
"v<"| ">A"
..
```

### Expanding a sequence
This is the function `.d21.single`.

For demonstration, let's use `seq:"029A"`.

Instead of keeping the entire sequence in memory, we split it up to fragments and only keep the
occurrence count for each fragment. This is necessary for part 2, as the extra keypads would cause
the sequence to not fit into memory.

We define an expansion function that takes a sequence and returns the fragments based on the
sequence needed to press all the keys using the arrow keypad. Note that this time we have to
explicitly drop the `""` element that gets added in due to `':` calling the function with the first
element and a null value which has no corresponding sequence. The `.d21.keypathExt` function didn't
suffer from this as the cross product would simply concatenate the empty string to all the
sequences, which doesn't change them at all.
```q
    f:{[x;p]count each enlist[""]_group{x y,z}[p]':["A",x]};
```
We use the function to expand the initial sequence, which is on the numeric keypad:
```q
q)press:f[seq;.d21.kpNumExt]
q)press
"<A"  | 1
"^A"  | 1
"^^>A"| 1
"vvvA"| 1
```
Then we iterate a certain number of times (this is a parameter to the function). In each iteration,
we call `f` on the _keys_ of the dictionary, multiply the results with the _values_, and then sum
the list of dictionaries for deduplication:
```q
q)press:sum(f[;.d21.kpArrowExt]each key press)*value press
q)press
"v<<A"| 1
">>^A"| 1
"<A"  | 2
">A"  | 1
,"A"  | 3
"v>A" | 1
"^A"  | 1
"<vA" | 1
"^>A" | 1
q)press:sum(f[;.d21.kpArrowExt]each key press)*value press
q)press
"<vA" | 2
"<A"  | 3
,"A"  | 5
">>^A"| 3
"vA"  | 2
"<^A" | 1
">A"  | 4
"v<<A"| 3
"^A"  | 3
"^>A" | 1
"v>A" | 1
```
To figure out the total number of keypresses, we need to multiply the lengths of the sequences that
are the keys of the dictionary by the corresponding values:
```q
q)(count each key press)*value press
6 6 5 12 4 3 8 12 6 3 3
q)sum(count each key press)*value press
68
```

### Processing a full input
This is the function `d21`. It takes the iteration count as a parameter in addition to the input.

We find the length of the keypress sequence for each line in the input:
```q
q).d21.single[iter]each x
68 60 68 64 64
```
We remove all the "A" characters and parse the remaining strings as integers:
```q
q)"J"$x except\:"A"
29 980 179 456 379
```
We multiply and then sum these lists:
```q
q)sum(.d21.single[iter]each x)*"J"$x except\:"A"
126384
```

## Part 1
The iteration count is 1.

## Part 2
The iteration count is 24. Not 25 as I would have expected, which means I failed this part
originally because there is no example output provided for comparison, so I had to take a leap of
faith. For the record the example output would be 154115708116294.
