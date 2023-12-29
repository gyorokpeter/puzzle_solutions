# Breakdown

Example input:
```q
x:();
x,:enlist"Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53";
x,:enlist"Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19";
x,:enlist"Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1";
x,:enlist"Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83";
x,:enlist"Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36";
x,:enlist"Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11";
```

## Common

We need to find out the number of winning numbers on each card.

We split on `": "` first, drop the first element (since the card number can be re-derived later), then split on " | " then on " " to separate the numbers. Due to the possibility of multiple spaces between numbers, there will be nulls in the result which we must remove.
```q
q)last each": "vs/:x
"41 48 83 86 17 | 83 86  6 31 17  9 48 53"
"13 32 20 16 61 | 61 30 68 82 17 32 24 19"
" 1 21 53 59 44 | 69 82 63 72 16 21 14  1"
"41 92 73 84 69 | 59 84 76 51 58  5 54 83"
"87 83 26 28 32 | 88 30 70 12 93 22 82 36"
"31 18 13 56 72 | 74 77 10 23 35 67 36 11"
q)" | "vs/:last each": "vs/:x
"41 48 83 86 17" "83 86  6 31 17  9 48 53"
"13 32 20 16 61" "61 30 68 82 17 32 24 19"
" 1 21 53 59 44" "69 82 63 72 16 21 14  1"
"41 92 73 84 69" "59 84 76 51 58  5 54 83"
"87 83 26 28 32" "88 30 70 12 93 22 82 36"
"31 18 13 56 72" "74 77 10 23 35 67 36 11"
q)"J"$" "vs/:/:" | "vs/:last each": "vs/:x
41 48 83 86 17   83 86 0N 6 31 17 0N 9 48 53
13 32 20 16 61   61 30 68 82 17 32 24 19
0N 1 21 53 59 44 69 82 63 72 16 21 14 0N 1
41 92 73 84 69   59 84 76 51 58 0N 5 54 83
87 83 26 28 32   88 30 70 12 93 22 82 36
31 18 13 56 72   74 77 10 23 35 67 36 11
q)a:("J"$" "vs/:/:" | "vs/:last each": "vs/:x)except\:\:0N
q)a
41 48 83 86 17 83 86 6 31 17 9 48 53
13 32 20 16 61 61 30 68 82 17 32 24 19
1 21 53 59 44  69 82 63 72 16 21 14 1
41 92 73 84 69 59 84 76 51 58 5 54 83
87 83 26 28 32 88 30 70 12 93 22 82 36
31 18 13 56 72 74 77 10 23 35 67 36 11
```
The winning numbers are the intersection between the first and second part of each line, and we only need the count, not the actual numbers.
```q
q)a[;0]inter'a[;1]
48 83 86 17
32 61
1 21
,84
`long$()
`long$()
q)count each a[;0]inter'a[;1]
4 2 2 1 0 0
```

We call the function that performs this calculation `d4`.

## Part 1

Each card is worth 2 to the power of one less than the number of winning numbers, except the cards with no winning numbers which are worth no points.
```q
q)c:d4 x
q)2 xexp -1+c except 0
8 2 2 1f
q)sum`long$2 xexp -1+c except 0
13
```

## Part 2

I used an iterative solution to this since the numbers are sequentially dependent. We start with a list containing the number 1 for each card (`count[c]#1`). We iterate over the indices of the cards (`til count c`). In each step of the iteration we add the number of cards in the current position (`x[y]`) to the next cards that we won (`y+1+til c y`) and return the modified list. Here is the iteration using `\` (scan) to show the intermediate results:
```q
q)c:d4 x
q){[c;x;y]x[y+1+til c y]+:x[y];x}[c]\[count[c]#1;til count c]
1 2 2 2 2  1
1 2 4 4 2  1
1 2 4 8 6  1
1 2 4 8 14 1
1 2 4 8 14 1
1 2 4 8 14 1
```
The answer is the sum of the final state, so we only need to use `/` (over):
```q
q){[c;x;y]x[y+1+til c[y]]+:x[y];x}[c]/[count[c]#1;til count c]
1 2 4 8 14 1
q)sum{[c;x;y]x[y+1+til c[y]]+:x[y];x}[c]/[count[c]#1;til count c]
30
```