# Breakdown

Example input:
```q
x:"\n"vs"#####\n.####\n.####\n.####\n.#.#.\n.#...\n.....\n";
x,:"\n"vs"#####\n##.##\n.#.##\n...##\n...#.\n...#.\n.....\n";
x,:"\n"vs".....\n#....\n#....\n#...#\n#.#.#\n#.###\n#####\n";
x,:"\n"vs".....\n.....\n#.#..\n###..\n###.#\n###.#\n#####\n";
x,:"\n"vs".....\n.....\n.....\n#....\n#.#..\n#.#.#\n#####";
```

We spit the input into groups and then convert it to booleans by comparing with `"#"`:
```q
q)a:"#"="\n"vs/:"\n\n"vs"\n"sv x
q)a
11111b 01111b 01111b 01111b 01010b 01000b 00000b
11111b 11011b 01011b 00011b 00010b 00010b 00000b
00000b 10000b 10000b 10001b 10101b 10111b 11111b
00000b 00000b 10100b 11100b 11101b 11101b 11111b
00000b 00000b 00000b 10000b 10100b 10101b 11111b
```
We find which groups are keys by checking if their first row is all ones:
```q
q)isKey:all each first each a
q)isKey
11000b
```
We count how many ones there are in every group. We can rely on `sum` collapsing the lists
vertically, and we don't have to worry about whether a group is a lock or key because the input is
well-formed so there are no breaks in it:
```q
q)cnts:sum each a
q)cnts
1 6 4 5 4
2 3 1 6 4
6 1 3 2 4
5 4 5 1 3
4 1 3 1 2
```
We separate out the counts for the locks and the keys:
```q
q)ky:cnts where isKey
q)lk:cnts where not isKey
q)ky
1 6 4 5 4
2 3 1 6 4
q)lk
6 1 3 2 4
5 4 5 1 3
4 1 3 1 2
```
We pair up each lock with each key and add the corresponding elements together:
```q
q)ky+/:\:lk
7 7  7 7 8 6 10 9 6 7 5 7  7 6 6
8 4 4 8 8  7 7 6 7 7  6 4 4 7 6
```
A good match doesn't contain any numbers exceeding the vertical size of a lock/key:
```q
q)(ky+/:\:lk)<=count first a
11110b 10011b 11111b
01100b 11111b 11111b
q)all each/:(ky+/:\:lk)<=count first a
001b
011b
```
The answer is the overall sum of this matrix:
```q
q)sum sum all each/:(ky+/:\:lk)<=count first a
3i
```
