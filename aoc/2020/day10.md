# Breakdown
Example input:
```q
x:"\n"vs"16\n10\n15\n5\n1\n11\n7\n19\n6\n12\n4"
```

## Part 1

We parse the integers:
```q
q)"J"$x
16 10 15 5 1 11 7 19 6 12 4
```
We put them in ascending order:
```q
q)asc"J"$x
`s#1 4 5 6 7 10 11 12 15 16 19
```
We use [`deltas`](https://code.kx.com/q/ref/deltas/) to find the consecutive differences:
```q
q)deltas asc"J"$x
1 3 1 1 1 3 1 1 3 1 3
```
We add a 3 to account for the required output. We could add it at the beginning or the end, but
adding it at the beginning is simpler syntax due to not needing parentheses.
```q
q)3,deltas asc"J"$x
3 1 3 1 1 1 3 1 1 3 1 3
```
We check the amount of each number in this list. This is the very common `count each group` idiom.
```q
q)count each group 3,deltas asc"J"$x
3| 5
1| 7
```
The answer is the product of the counts.
```q
q)prd count each group 3,deltas asc"J"$x
35
```
(This takes advantage of the fact that the input only ever contains differences of 1 or 3.)

## Part 2
An ugly iterative solution that fills up an array with the number of possibilities. Here is how the
array fills up for the example input, with the brackets indicating the current index:
```q
 0 1 4 5 6 7 10 11 12 15 16 19 22
[1]0 0 0 0 0  0  0  0  0  0  0  0
 1[1]0 0 0 0  0  0  0  0  0  0  0
 1 1[1]0 0 0  0  0  0  0  0  0  0
 1 1 1[1]1 1  0  0  0  0  0  0  0
 1 1 1 1[2]2  0  0  0  0  0  0  0
 1 1 1 1 2[4] 0  0  0  0  0  0  0
 1 1 1 1 2 4 [4] 0  0  0  0  0  0
 1 1 1 1 2 4  4 [4] 4  0  0  0  0
 1 1 1 1 2 4  4  4 [8] 0  0  0  0
 1 1 1 1 2 4  4  4  8  8  0  0  0
```
We convert the input to integers and sort like part 1:
```q
q)a:asc"J"$x
q)a
`s#1 4 5 6 7 10 11 12 15 16 19
```
We prepend a zero (the initial state) and the implicit final adapter:
```q
q)b:0,a,3+last a
q)b
0 1 4 5 6 7 10 11 12 15 16 19 22
```
Next comes our iteration function. It should take two parameters but because of how the `/` (over)
iterator works in q, it's easier to pass in a two-element list and unpack/modify the elements as
necessary. The first parameter is the current index, and the second is the array of possibilities
counted so far. We initialize the index to zero and the array to all zeros except the first element
which is a one, as there is only one way to choose zero adapters.
```q
q)s:(0;1,(count[b]-1)#0)
q)
0
1 0 0 0 0 0 0 0 0 0 0 0 0
```
On the other hand we need to pass in the joltage values (the `b` variable) because the function
can't see the local variables of the enclosing function. Therefore the function will look like this:
```q
    {[b;s]
    ...
    }[b]
```
where `s` is the list `(index;combinations)`.

In the function, first we check if we need to exit, which is when the index points at the last
element in the array. Since expansion only modifies elements at higher indices than the current one,
we don't have to expand the last index. We return the `s` parameter unmodified, which will cause the
iteration to stop.
```q
    if[s[0]>=count[b]-1;:s];
```
Otherwise, we expand the current element. This is better illustrated in an intermediate state:
```q
q)s:(2;1 1 1 0 0 0 0 0 0 0 0 0 0)
```
We first have to find the cut point where the adaptors can be used from the joltage at the current
index. We use [`binr`](https://code.kx.com/q/ref/bin/) (not `bin` because if we don't have the exact
target value, `bin` returns the index to the left of the missing value, while `binr` returns one on
the right). The first incompatible adapter has a value of at least 4 higher than the current one.
```q
q)b[s 0]
4
q)b[s 0]+4
8
q)b binr b[s 0]+4
6
```
(Note that `bin` would return 5 instead of 6 in this case.)

To get the indices to update, we first find the number of indices we need. This is done by
subtracting one plus the current index from the cut point:
```q
q)(b binr b[s 0]+4)-1+s 0
3
```
Then we generate the indices using `til` and shift them into place by adding the current index plus
one:
```q
q)til(b binr b[s 0]+4)-1+s 0
0 1 2
q)s[0]+1+til(b binr b[s 0]+4)-1+s 0
3 4 5
```
We would normally also have to clamp the highest index to make sure we don't index out of the array,
but because of how the implicit last element is constructed, this will actually never happen anyway.

We add the value at the current index to the values at the target indices:
```q
q)s[1;s[0]+1+til(b binr b[s 0]+4)-1+s 0]+:s[1;s 0]
q)s
2
1 1 1 1 1 1 0 0 0 0 0 0 0
```
The returned state is the same with the current index incremented by one.
```q
q)(s[0]+1;s[1])
3
1 1 1 1 1 1 0 0 0 0 0 0 0
```
We now have all the pieces to perform the iteration:
```q
    c:{...}[b]/[(0;1,(count[b]-1)#0)]
q)c
12
1 1 1 1 2 4 4 4 8 8 8 8 8
```
The answer is the last element of the array which is itself the last element of the iteration state.
```q
q)last last c
8
```
