# Breakdown

Example input:
```q
x:();
x,:"\n"vs"#.##..##.\n..#.##.#.\n##......#\n##......#\n..#.##.#.\n..##..##.\n#.#.##.#.\n";
x,:"\n"vs"#...##..#\n#....#..#\n..##..###\n#####.##.\n#####.##.\n..##..###\n#....#..#";
```

## Common
The logic works by indexing into the rows/columns with all possible positions of the mirror and check if the two halves are the same. To aid with this, we precalculate the indices for each possible mirror position on each possible field size (which can only be one of `7 9 11 13 15 17` in the input):
```q
.d13.ind:{x!{[c]i1:{((til x);x+reverse til x)}each 1+til c div 2;
    i2:i1,reverse each reverse(c-1)-i1}each x}7 9 11 13 15 17;
```
```q
q).d13.ind
7 | ((,0;,1);(0 1;3 2);(0 1 2;5 4 3);(1 2 3;6 5 4);(3 4;6 5);(,5;,6))
9 | ((,0;,1);(0 1;3 2);(0 1 2;5 4 3);(0 1 2 3;7 6 5 4);(1 2 3 4;8 7 6 5);(3 4..
11| ((,0;,1);(0 1;3 2);(0 1 2;5 4 3);(0 1 2 3;7 6 5 4);(0 1 2 3 4;9 8 7 6 5);..
13| ((,0;,1);(0 1;3 2);(0 1 2;5 4 3);(0 1 2 3;7 6 5 4);(0 1 2 3 4;9 8 7 6 5);..
15| ((,0;,1);(0 1;3 2);(0 1 2;5 4 3);(0 1 2 3;7 6 5 4);(0 1 2 3 4;9 8 7 6 5);..
17| ((,0;,1);(0 1;3 2);(0 1 2;5 4 3);(0 1 2 3;7 6 5 4);(0 1 2 3 4;9 8 7 6 5);..
```

The common logic (`.d13.findMirror`) takes a list of booleans for a single field:
```q
q)n
101100110b
001011010b
110000001b
110000001b
001011010b
001100110b
101011010b
```
For a little performance gain we convert these into integers by treating them as base-2 numbers, both horizontally and vertically:
```q
q)nh:2 sv/:n; nv:2 sv/:flip n;
q)nh
358 90 385 385 90 102 346
q)nv
89 24 103 66 37 37 66 103 24
```
We use the same functin to find a mirror in the horizontal and the vertical number list. This uses the precalculated indices to pick numbers from the list and compare them, and returns which positions result in a match, if any:
```q
q)fl2 nv
,5
q)fl2 nh
`long$()
```
To comply with the format of the input, we multiply the index of any horizontal mirror by 100, but we still return the result as a list:
```q
q)fl2[nv],100*fl2[nh]
,5
```

## Part 1
To split the input, we first join with `"\n"` and split on `"\n\n"`, then split again on `"\n"`:
```q
q)"\n"vs/:"\n\n"vs"\n"sv x
"#.##..##." "..#.##.#." "##......#" "##......#" "..#.##.#." "..##..##." "#.#...
"#...##..#" "#....#..#" "..##..###" "#####.##." "#####.##." "..##..###" "#.....
```
We convert the input to booleans by comparing each character to `"#"`:
```q
q)a:"#"="\n"vs/:"\n\n"vs"\n"sv x
q)a
101100110b 001011010b 110000001b 110000001b 001011010b 001100110b 101011010b
100011001b 100001001b 001100111b 111110110b 111110110b 001100111b 100001001b
```
We call the common logic which returns a list of lists. We raze them and sum to get the answer.
```q
q).d13.findMirror each a
5
400
q)sum raze .d13.findMirror each a
405
```

## Part 2
The input parsing is the same. For part 2 we try changing every single tile in the field by inverting it and check if any new mirror locations are introduced. This is why the common logic returns a list, as it is possible that the original mirror position still remains valid after the change but we need to disregard it. So first we save the mirror position with no change, then generate all the possible row+column index pairs (`inds:til[count[n]]cross til count first n`) and the corresponding modified fields (`.[n;;not]each inds`) and use `.d13.findMirror` again to find potential mirrors in each of them. We then remove the previously saved "default" mirror location and we should be left with only (copies of) one alternative mirror location. The function that expresses this:
```q
    f:{[n]def:.d13.findMirror n; inds:til[count[n]]cross til count first n;
        (distinct raze .d13.findMirror each .[n;;not]each inds)except def};
```
Like with part 1, we call this on every field, then raze and sum the results.
```q
q)f each a
300
100
q)sum raze f each a
400
```
