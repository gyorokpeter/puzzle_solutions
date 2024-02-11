# Breakdown
Example input:
```q
x:"7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1\n"
x,:"\n22 13 17 11  0\n 8  2 23  4 24\n21  9 14 16  7\n 6 10  3 18  5\n 1 12 20 1"
x,:"5 19\n\n 3 15  0  2 22\n 9 18 13 17  5\n19  8  7 25 23\n20 11 10 24  4\n14 21"
x,:" 16 12  6\n\n14 21 17 24  4\n10 16 15  9 19\n18  8 23 26 20\n22 11 13  6  5\n"
x,:" 2  0 12  3  7"
```

## Common
As usual we split the input into lines:
```q
q)a:"\n"vs x
q)a
"7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1"
""
"22 13 17 11  0"
" 8  2 23  4 24"
"21  9 14 16  7"
" 6 10  3 18  5"
" 1 12 20 15 19"
...
```
Then we split the number calls on commas and convert the result to integers:
```q
q)call:"J"$","vs a[0];
q)call
7 4 9 5 11 17 23 2 0 14 21 24 10 16 13 6 15 25 12 22 18 20 8 19 3 26 1
```
To process the boards, we first remove the first line (`1_`) and then cut the remaining list to
6 elements each:
```q
q)6 cut 1_a
"" "22 13 17 11  0" " 8  2 23  4 24" "21  9 14 16  7" " 6 10  3 18  5" " 1 12..
"" " 3 15  0  2 22" " 9 18 13 17  5" "19  8  7 25 23" "20 11 10 24  4" "14 21..
"" "14 21 17 24  4" "10 16 15  9 19" "18  8 23 26 20" "22 11 13  6  5" " 2  0..
```
We also remove the initial blank line from each element:
```q
q)1_/:6 cut 1_a
"22 13 17 11  0" " 8  2 23  4 24" "21  9 14 16  7" " 6 10  3 18  5" " 1 12 20..
" 3 15  0  2 22" " 9 18 13 17  5" "19  8  7 25 23" "20 11 10 24  4" "14 21 16..
"14 21 17 24  4" "10 16 15  9 19" "18  8 23 26 20" "22 11 13  6  5" " 2  0 12..
```
Then we split the individual lines on spaces and convert the result to integers:
```q
q)"J"$" "vs/:/:1_/:6 cut 1_a
22 13 17 11 0N 0     0N 8 0N 2 23 0N 4 24 21 0N 9 14 16 0N 7 0N 6 10 0N 3 18 ..
0N 3 15 0N 0 0N 2 22 0N 9 18 13 17 0N 5   19 0N 8 0N 7 25 23 20 11 10 24 0N 4..
14 21 17 24 0N 4     10 16 15 0N 9 19     18 0N 8 23 26 20   22 11 13 0N 6 0N..
```
Note the null elements, which is because of the extra spaces in the input. We remove them using
[`except`](https://code.kx.com/q/ref/except/):
```q
q)("J"$" "vs/:/:1_/:6 cut 1_a)except\:\:0N
22 13 17 11 0  8  2  23 4  24 21 9  14 16 7  6  10 3  18 5  1  12 20 15 19
3  15 0  2  22 9  18 13 17 5  19 8  7  25 23 20 11 10 24 4  14 21 16 12 6
14 21 17 24 4  10 16 15 9  19 18 8  23 26 20 22 11 13 6  5  2  0  12 3  7
```
This is still a three-dimensional list, but for easier handling, it's better to raze them such
that each board is a list of 25 numbers:
```q
q)boards:raze each ("J"$" "vs/:/:1_/:6 cut 1_a)except\:\:0N;
q)boards
22 13 17 11 0  8  2  23 4  24 21 9 14 16 7  6  10 3  18 5 1  12 20 15 19
3  15 0  2  22 9  18 13 17 5  19 8 7  25 23 20 11 10 24 4 14 21 16 12 6
14 21 17 24 4  10 16 15 9  19 18 8 23 26 20 22 11 13 6  5 2  0  12 3  7
```
Next we find when each number is called using the `?` operator. The left operand is the list that we
are searching in, and the right operand is the elements we are searching for. It extends to lists
on the right, so we can give it the full list of boards.
```q
q)round:call?boards
q)round
19 14 5 4  8  22 7  6  1 11 10 2  9 13 0  15 12 24 20 3 26 18 21 16 23
24 16 8 7  19 2  20 14 5 3  23 22 0 17 6  21 4  12 11 1 9  10 13 18 15
9  10 5 11 1  12 13 16 2 23 20 22 6 25 21 19 4  14 15 3 7  8  18 24 0
```
Now we need to check when each board wins. To do this we need the indices of what counts as a line.
This can be done using simple arithmetic:
```q
q)lines:0 5 10 15 20 0 1 2 3 4+1 1 1 1 1 5 5 5 5 5*\:til 5;
q)lines
0  1  2  3  4
5  6  7  8  9
10 11 12 13 14
15 16 17 18 19
20 21 22 23 24
0  5  10 15 20
1  6  11 16 21
2  7  12 17 22
3  8  13 18 23
4  9  14 19 24
```
To find when each line wins, first we need to use the lines as indices into every card. So we need
to use the `@` indexing operator with each-left (`\:`). After that it works correctly (e.g.
`round[0][lines]` would retrieve each line for the first card).
```q
q)round@\:lines
19 14 5  4  8  22 7  6  1  11 10 2  9  13 0  15 12 24 20 3  26 18 21 16 23 19..
24 16 8  7  19 2  20 14 5  3  23 22 0  17 6  21 4  12 11 1  9  10 13 18 15 24..
9  10 5  11 1  12 13 16 2  23 20 22 6  25 21 19 4  14 15 3  7  8  18 24 0  9 ..
```
To find when each line wins, we need to find the maximum, since a line wins if all the numbers in
it are called:
```q
q)max each/:round@\:lines
19 22 13 24 26 26 18 24 20 23
24 20 23 21 18 24 22 14 18 19
11 23 25 19 24 20 22 18 25 23
```
But to find when each card wins, we need to take the minimum of the line wins, since a card wins if
at least one line on it wins:
```q
q)boardWinRounds:min each max each/:round@\:lines
q)boardWinRounds
13 14 11
```

For part 1 we can take the minimum of these to find which card wins first:
```q
q)winRound:min boardWinRounds
q)winRound
11
```
For part 2 the we need to take the maximum instead.

Since we just reduced the list to a single number, we need to look up which board actually has this
number:
```q
q)winBoard:first where winRound=boardWinRounds
q)winBoard
2
```
The unmarked numbers are those that are called later than the winRound:
```q
q)round[winBoard]>winRound
0000011101110111011000110b
q)boards[winBoard] where round[winBoard]>winRound
10 16 15 19 18 8 26 20 22 13 6 12 3
```
So now we have all parts for the solution:
```q
q)call[winRound]
24
q)sum boards[winBoard] where round[winBoard]>winRound
188
q)call[winRound]*sum boards[winBoard] where round[winBoard]>winRound
4512
```

The only difference between part 1 and 2 is whether `winRound` is calculated using `max` or
`min`. Therefore I made this solution a single lambda that takes an operator as an argument and calls
it on `boardWinRounds`. Part 1 passes in `min` and part 2 passes in `max`:
```q
d4p1:{d4[min;x]};
d4p2:{d4[max;x]};
```
