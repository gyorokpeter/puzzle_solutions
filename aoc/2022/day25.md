# Breakdown
Example input:
```q
x:"\n"vs"1=-0-2\n12111\n2=0=\n21\n2=01\n111\n20012\n112\n1=-1=\n1-12\n12\n1=\n122";
```

## Part 1
We map the digits to their numerical values:
```q
q)digits:("=-012"!-2+til 5);
q)digits x
1 -2 -1 0 -1 2
1 2 1 1 1
2 -2 0 -2
..
```
The [`sv`](https://code.kx.com/q/ref/sv/#base-to-integer) operator for converting from a list of digits to an integer doesn't care that we have negative "digits" in our list, it works just fine:
```q
q)5 sv/:digits x
1747 906 198 11 201 31 1257 32 353 107 7 3 37
q)sum 5 sv/:digits x
4890
```
On the other hand, `vs` will generate digits between 0 and 4:
```q
q)s:5 vs sum 5 sv/:digits x;
q)s
1 2 4 0 3 0
```
This can be fixed using a "carry" process similar to what we do when adding decimal numbers on paper. Whenever we run into a digit that is larger than 2, we subtract 5 from that digit and add 1 to the digit in the next place. We might need to repeat this process, so we need to iterate this as a function. Also we need to make sure to add a new digit at the beginning if the first digit happens to be larger than 2.
```q
q){[s]if[first[s]>2; s:0,s];s+next[s>2]+(s>2)*-5}/[s]
2 -2 -1 1 -2 0
```
For output we map the digits using the dictionary we used at the beginning but with a reverse lookup.
```q
q)digits?{[s]if[first[s]>2; s:0,s];s+next[s>2]+(s>2)*-5}/[s]
"2=-1=0"
```
