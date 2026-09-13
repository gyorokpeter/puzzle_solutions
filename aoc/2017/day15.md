# Breakdown
Example input:
```q
q)x:("Generator A starts with 65";"Generator B starts with 8921")
```
(This input is synthetic, as it doesn't appear in this form in the puzzle. It follows the format of
the real input but has the numbers from the example.)

## Common
We use a common function that performs an iteration and sums up the result. The function takes 4
parameters:
* `x`: the puzzle input
* `n`: the number of steps
* `fa`: the function to apply to `a`
* `fb`: the function to apply to `b`

Using a fictional combination:
```q
q)n:2000000
q)fa:1+
q)fb:2+
```
We parse the input by splitting on spaces, taking the last element of each line and converting to
integers:
```q
q)p:"J"$last each" "vs/:x
q)p
65 8921
```
We assign the initial values for `a` and `b`:
```q
q)a:p 0;b:p 1
q)a
65
q)p
65 8921
```
We set the chunk size to 1000000 (this is arbitrary but it must be a divisor of `n`). We initialize
a starting index and a total to accumulate the matches for the answer.
```q
q)chunksize:1000000
q)start:0
q)total:0
```
The reason for chunking is that the calculation is "embarrassingly sequential", i.e. the antithesis
of what q is optimized for, and takes much longer than the equivalent in a more common language. On
my machine as of this writing, part 1 takes 60 seconds and part 2 takes 70 seconds, so it's a good
idea to show some visualization of progress.

We iterate until the starting index reaches the total number of steps, and print the current
starting position using `0N!`:
```q
    while[(0N!start)<n;
        ...
    ];
```
In the iteration, we call the functions `fa` and `fb` using `\` (scan) to generate a chunk of
intermediate values:
```q
q)as:1_fa\[chunksize;a]
q)bs:1_fb\[chunksize;b]
q)as
66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98..
q)bs
8923 8925 8927 8929 8931 8933 8935 8937 8939 8941 8943 8945 8947 8949 8951 8953 8955 8957 8959 896..
```
We calculate the number of matches modulo 65535 and add them to the running total:
```q
q)total+:sum(as mod 65536)=bs mod 65536
q)total
15
```
We update the next start position and the starting values for `a` and `b`:
```q
q)start+:chunksize
q)a:last as
q)b:last bs
q)start
1000000
q)a
1000065
q)b
2008921
```
The code for the iteration ends here. At the end of the iteration, we have the total matches in the
`total` variable, which is also the answer to the respective puzzle parts:
```q
q)total
30
```

## Part 1
We call the common function with a step count of 40000000 and the required calculations:
```q
q)fa:{[a](a*16807)mod 2147483647}
q)fb:{[b](b*48271)mod 2147483647}
q)d15[x;40000000;fa;fb]
0
1000000
2000000
3000000
..
38000000
39000000
40000000
588
```

## Part 2
We call the common function with a step count of 5000000 and the required calculations. The
calculation functions now include an inner loop to keep generating until they find a number that is
a multiple of the given factor. The loop body is empty as both the calculation and the check are
done in the condition.
```q
q)fa:{[a]while[[a:(a*16807)mod 2147483647;a mod 4]];a}
q)fb:{[b]while[[b:(b*48271)mod 2147483647;b mod 8]];b}
q)d15[x;5000000;fa;fb]
0
1000000
2000000
3000000
4000000
5000000
309
```
