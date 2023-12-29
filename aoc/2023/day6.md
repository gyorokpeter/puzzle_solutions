# Breakdown

Example input:
```q
x:"\n"vs"Time:      7  15   30\nDistance:  9  40  200";
```
## Part 1
We split the input on `": "` and keep only the second part, then we split on `" "` and parse the numbers. Due to the variable number of spaces, there will be nulls after parsing, so we filter them out.
```q
q)a:("J"$" "vs/:last each":"vs/:x)except\:0N
q)a
7 15 30
9 40 200
```
For each race time, we try every possible charge-up period. There is no point in checking a charge time of zero, nor a charge time equal to the race time, so we only generate the numbers from 1 to the time minus 1.
```q
q)1+til each -1+a 0
1 2 3 4 5 6
1 2 3 4 5 6 7 8 9 10 11 12 13 14
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
```
We can find the distance travelled by multiplying each list by its reverse:
```q
q){x*reverse x}each 1+til each -1+a 0
6 10 12 12 10 6
14 26 36 44 50 54 56 56 54 50 44 36 26 14
29 56 81 104 125 144 161 176 189 200 209 216 221 224 225 224 221 216 209 200 ..
```
We are looking for which distances are larger than the race distance:
```q
q)a[1]<{x*reverse x}each 1+til each -1+a 0
011110b
00011111111000b
00000000001111111110000000000b
```
To get the answer, we sum the lists and then take the product of the results:
```q
q)sum each a[1]<{x*reverse x}each 1+til each -1+a 0
4 8 9i
q)sum each a[1]<{x*reverse x}each 1+til each -1+a 0
4 8 9i
q)prd sum each a[1]<{x*reverse x}each 1+til each -1+a 0
288i
```

## Part 2
The solution is the same, except we remove the spaces when parsing the numbers, and we don't need so many `each`es as there is now only one race as opposed to a list of them:
```q
q)a:"J"$(last each":"vs/:x)except\:" "
q)a
71530 940200
q)1+til -1+a 0
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29..
q)a[1]<{x*reverse x}1+til -1+a 0
00000000000001111111111111111111111111111111111111111111111111111111111111111..
q)sum a[1]<{x*reverse x}1+til -1+a 0
71503i
```
