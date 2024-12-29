# Breakdown

## Common
We define a constant for the mask used by the pruning operation:
```q
q).d22.mask:(8#0b),24#1b;
q).d22.mask
00000000111111111111111111111111b
```

We also define the `.d22.nxt` function that calculates the next number in a sequence. For
demonstration, let's use `nb:00000000000000000000000001111011b` (the binary representation of 123).
```q
q)nb2:.d22.mask and (6_nb,000000b)<>nb
q)nb2
00000000000000000000000000111111b
q)nb3:.d22.mask and (00000b,-5_nb2)<>nb2
q)nb3
00000000000000000000000000111110b
q).d22.mask and (11_nb3,00000000000b)<>nb3
00000000000000011111000000111110b
```
We can iterate this to get a sequence of bit lists. We can convert them back to integers to check
the values:
```q
q)0b sv/:.d22.nxt\[10;0b vs 123i]
123 15887950 16495136 527345 704524 1553684 12683156 11100544 12249484 7753432 5908254i
```

## Part 1
Example input:
```q
x:"\n"vs"1\n10\n100\n2024";
```

We parse the input as integers - notably this time we use `"I"` instead of the usual `"J"` to save
some memory:
```q
q)"I"$x
1 10 100 2024i
```
We split them into bits using `0b vs`:
```q
q)nbs:0b vs/:"I"$x
q)nbs
00000000000000000000000000000001b
00000000000000000000000000001010b
00000000000000000000000001100100b
00000000000000000000011111101000b
```
We call the next-number function 2000 times on each list:
```q
q)nbs2:.d22.nxt/[2000;]each nbs
q)nbs2
00000000100001001000011101110101b
00000000010001111011101100110010b
00000000111010010000111011011100b
00000000100001000100000110000100b
```
We convert them back to integers and sum them. The cast to `long` is not for the aesthetics, but
because even though the numbers don't overflow the `int` type, their sum will on the real input.
```q
q)0b sv/:nbs2
8685429 4700978 15273692 8667524i
q)sum`long$0b sv/:nbs2
37327623
```

## Part 2
Example input:
```q
x:"\n"vs"1\n2\n3\n2024";
```
We generate the bit sequences as in part 1 and generate 2000 numbers each, but we keep the
intermediate results and convert all back to integers:
```q
q)nbs:0b vs/:"I"$x;
nbs2:0b sv/:/:.d22.nxt\[2000;]each nbs;
q)nbs2
1    137283  12980423 12601359 1593745  11512959 16221730 14681815 1230479  5592677  4860252 28215..
2    274566  8659342  8966174  3154210  7262959  1018470  3257209  7145040  10217154 4637936 13238..
3    403653  4337993  4757521  2650291  12680848 16256068 13743534 8372447  13545639 847276  14873..
2024 9554439 6855065  897063   12842024 7455193  13668901 3034046  11647263 13650217 6259570 96207..
```
We get the prices by modulo'ing the numbers by 10:
```q
q)price:nbs2 mod 10
q)price
1 3 3 9 5 9 0 5 9 7 2 0 1 3 9 8 5 7 6 6 9 3 7 5 2 1 3 8 5 3 5 2 5 8 8 7 4 0 7 3 5 6 3 7 0 1 5 5 8 ..
2 6 2 4 0 9 0 9 0 4 6 1 0 5 6 6 6 8 1 3 0 1 0 4 8 0 5 3 3 1 8 3 5 9 9 6 0 3 6 5 8 9 5 4 1 9 8 7 8 ..
3 3 3 1 1 8 8 4 7 9 6 1 7 2 7 2 7 7 7 7 5 6 3 7 0 5 0 1 6 2 5 9 0 7 3 7 0 7 7 2 1 3 6 9 1 0 5 4 2 ..
4 9 5 3 4 3 1 6 3 7 0 9 9 2 6 9 0 9 8 8 1 2 7 5 9 0 9 2 8 3 3 1 2 7 8 9 0 1 7 2 4 1 8 3 2 9 2 1 5 ..
```
We find the changes between the prices and drop the first element added by `deltas` as it is not
relevant:
```q
q)chg:1_/:deltas each price
q)chg
2 0  6  -4 4  -9 5  4  -2 -5 -2 1  2  6 -1 -3 2 -1 0 3  -6 4  -2 -3 -1 2  5  -3 -2 2 -3 3  3 0  -1..
4 -4 2  -4 9  -9 9  -9 4  2  -5 -1 5  1 0  0  2 -7 2 -3 1  -1 4  4  -8 5  -2 0  -2 7 -5 2  4 0  -3..
0 0  -2 0  7  0  -4 3  2  -3 -5 6  -5 5 -5 5  0 0  0 -2 1  -3 4  -7 5  -5 1  5  -4 3 4  -9 7 -4 4 ..
5 -4 -2 1  -1 -2 5  -3 4  -7 9  0  -7 4 3  -9 9 -1 0 -7 1  5  -2 4  -9 9  -7 6  -5 0 -2 1  5 1  1 ..
```
We take every single subsequence of length 4 by generating the relevant indices. Only the first
element is shown for readability:
```q
q)(chg@/:\:til[1997]+\:til 4)0
2  0  6  -4
0  6  -4 4
6  -4 4  -9
-4 4  -9 5
4  -9 5  4
..
```
We group the sequences and take the first index from each group, which indicates where that sequence
occurs first. Again, only the first element is shown:
```q
q)(group each chg@/:\:til[1997]+\:til 4)0
2  0  6  -4| ,0
0  6  -4 4 | ,1
..
-2 1  2  6 | ,10
1  2  6  -1| 11 1703
2  6  -1 -3| ,12
6  -1 -3 2 | 13 600
..
q)(first each/:group each chg@/:\:til[1997]+\:til 4)0
2  0  6  -4| 0
0  6  -4 4 | 1
..
-2 1  2  6 | 10
1  2  6  -1| 11
2  6  -1 -3| 12
6  -1 -3 2 | 13
..
```
We map the index into the corresponding price - note that we have to add 4 to the index, since the
index points at the beginning of the sequence and the price is at the end of it:
```q
q)gain:price@'4+first each/:group each chg@/:\:til[1997]+\:til 4
q)gain 0
2  0  6  -4| 5
0  6  -4 4 | 9
6  -4 4  -9| 0
-4 4  -9 5 | 5
4  -9 5  4 | 9
..
```
We sum the dictionaries to find the total gain from each sequence. The maximum of this is the
answer.
```q
q)sum gain
2  0  6  -4| 5
0  6  -4 4 | 9
6  -4 4  -9| 0
-4 4  -9 5 | 5
4  -9 5  4 | 9
..
q)max sum gain
23
```
