# Breakdown

## Part 1
Example input:
```q
x:"\n"vs"1abc2\npqr3stu8vwx\na1b2c3d4e5f\ntreb7uchet";
```

We need to keep only the digits from the input. The built-in variable `.Q.n` is defined as `"0123456789"`, so it is perfect for this filtering. We can use [`inter`](https://code.kx.com/q/ref/inter/) which returns the intersection between the two sets, keeping the left argument in order. Since we want to iterate over the left argument but not the right one, we use the `\:` (each-left) iterator.
```q
q)x inter\:1_.Q.n
"12"
"38"
"12345"
,"7"
```
We take the first and last element of each line (if there is only one element, the first and last are the same). Since we need to refer to the result of the above expression twice, we could either put it in a local variable or use a lambda. I chose the latter. We need to pairwise concatenate the two elements, so the `'` (each) iterator comes in handy.
```q
q)first each x inter\:1_.Q.n
"1317"
q)last each x inter\:1_.Q.n
"2857"
q){(first each x),'last each x}x inter\:1_.Q.n
"12"
"38"
"15"
"77"
```
We parse the resulting strings into integers with `"J"$` (see [Tok](https://code.kx.com/q/ref/tok/)).
```q
q)"J"${(first each x),'last each x}x inter\:1_.Q.n
12 38 15 77
```
We sum the results to get the answer for part 1.
```q
q)sum"J"${(first each x),'last each x}x inter\:1_.Q.n
142
```

## Part 2
Example input:
```q
x:"\n"vs"two1nine\neightwothree\nabcone2threexyz\nxtwone3four\n4nineeightseven2\nzoneight234\n7pqrstsixteen";
```
This time we also need to interpret the numbers written out in letters. One way to do it is to use [`ss`](https://code.kx.com/q/ref/ss/) (string search). Since we still need to watch out for actual digits as well, we can make a combined list of text and numeric digits to search for both. In the case of the numeric digits, we can use `.Q.n` before, but we need to `enlist` each character to make them individual strings instead of a single big string. We also drop the zero in `.Q.n` using `1_` because there is no zero in the input and it makes the next calculation a bit simpler.
```q
q)("one";"two";"three";"four";"five";"six";"seven";"eight";"nine"),enlist each 1_.Q.n
"one"
"two"
"three"
"four"
"five"
"six"
"seven"
"eight"
"nine"
,"1"
,"2"
,"3"
,"4"
,"5"
,"6"
,"7"
,"8"
,"9"
```
When searching for the digits, we use the `ss` operator with both `/:` (each-right) and `\:` (each-left). This is because we want to search for every digit in every string. The ordering of the two iterators matters, if we swap them, the resulting matrix will be flipped. With the ordering `/:\:` we get one row for each input line and one column for each digit.
```q
q)a:x ss/:\:("one";"two";"three";"four";"five";"six";"seven";"eight";"nine"),enlist each 1_.Q.n;
q)a
`long$() ,0       `long$() `long$() `long$() `long$() `long$() `long$() ,4   ..
`long$() ,4       ,7       `long$() `long$() `long$() `long$() ,0       `long..
,3       `long$() ,7       `long$() `long$() `long$() `long$() `long$() `long..
,3       ,1       `long$() ,7       `long$() `long$() `long$() `long$() `long..
`long$() `long$() `long$() `long$() `long$() `long$() ,10      ,5       ,1   ..
,1       `long$() `long$() `long$() `long$() `long$() `long$() ,3       `long..
`long$() `long$() `long$() `long$() `long$() ,6       `long$() `long$() `long..
```
Each cell in the result indicates what position(s) the digit appears in the input string. We have to find the minimum and maximum position in each line. This can be done by `raze`ing each line so we get a list of the positions and then taking the minimum and maximum of each row:
```q
q)pfirst:min each raze each a;
q)pfirst
0 0 3 1 0 1 0
q)plast:max each raze each a;
q)plast
4 7 7 7 15 10 6
```
We also need to look up what the actual digits are. We can refer back to the matrix and locate which cell the indices in `pfirst`/`plast` are in. We need to combine the `in` operator with `/:` first because for each row we have a single element on the left that we want to look up in a list of lists on the right, and then with `'` because we want to do this pairwise between the minimum/maximum locations and the rows of the matrix. There should be only one match the whole row so we can use `first` to get that one element.
```q
q)dfirst:first each where each pfirst in/:'a;
q)dfirst
1 7 0 1 12 0 15
q)dlast:first each where each plast in/:'a;
q)dlast
8 2 2 3 10 12 5
```
The results are indices in the original lookup list, and the value of the digit can be calculated from the index knowing that the indices 0\~8 correspond to the digits 1\~9 and the indices 9\~17 also correspond to 1\~9 (this is where removing the `"0"` comes in handy). So we can `mod` by 9 and add 1 (note the ordering of the operations).
```q
q)(1+til[18]mod 9)dfirst,'dlast
2 9
8 3
1 3
2 4
4 2
1 4
7 6
```
One of the uses of [`vs`](https://code.kx.com/q/ref/sv/#base-to-integer) is to convert a number from a list of digits in any base to a single number, so we can use this to "glue" the two digits together:
```
q)10 sv/:1+(dfirst,'dlast)mod 9
29 83 13 24 42 14 76
```
And like in part 1, the answer is the sum of these numbers:
```q
q)sum 10 sv/:1+(dfirst,'dlast)mod 9
281
```
