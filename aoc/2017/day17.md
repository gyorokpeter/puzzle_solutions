# Breakdown
The input is a single integer.

Example input:
```q
q)x:3
```

## Part 1
We use an iterated function with `/` (over). The function takes a fixed parameter for the step size.
The accumulator consists of three elements: the full list of numbers, the current position, and the
next number to insert. The list is originally just the single number 0, the position is 0 and the
next number is 1.
```q
q)step:3
q)bpv:(enlist 0;0;1)
q)bpv
,0
0
1
```
(`bpv` stands for "buffer, position, value").

The workings of the function are best demonstrated using a later iteration:
```q
q)bpv:(0 9 5 7 2 4 3 8 6 1;1;10)
```
In the iterated function, we first extract the buffer to a variable:
```q
q)buf:bpv[0]
q)buf
0 9 5 7 2 4 3 8 6 1
```
We find the next position by adding the step size to the current position, making sure to modulo it
by the buffer size:
```q
q)bpv[1]+step
4
q)count buf
10
q)pos:(bpv[1]+step) mod count buf
q)pos
4
```
We insert the current value into the buffer by taking the first `pos+1` elements and the last
elements after the `pos+1`th element, and putting the new value in the middle:
```q
q)(pos+1)#buf
0 9 5 7 2
q)(pos+1)_buf
4 3 8 6 1
q)bpv[0]:((pos+1)#buf),bpv[2],(pos+1)_buf
q)bpv[0]
0 9 5 7 2 10 4 3 8 6 1
```
We update the current position in the accumulator by adding one to the calculated position. Since we
just added a new element at `pos`, adding one to it will never wrap around.
```q
q)bpv[1]:pos+1
q)bpv[1]
5
```
We also increase the value to insert by 1:
```q
q)bpv[2]+:1
q)bpv[2]
11
```
This updated `bpv` is the return value, providing the accumulator for the next iteration.

We call the iterated function with `/` (over), using the overload that takes an iteration count and
an initial value of the accumulator:
```q
    bpv:{[step;bpv]
        ...
    bpv}[x]/[2017;(enlist 0;0;1)];
```
After the iteration, we have the final state:
```q
q)bpv
0 1226 1635 517 218 920 1636 1227 690 388 1637 291 1228 921 1638 518 691 1229 1639 16 922 92 1640 ..
1530
2018
```
To get the answer, we index into the buffer at the final position plus one. This may wrap around so
we need to mod it by the buffer size.
```q
q)(bpv[1]+1)mod count bpv[0]
1531
q)bpv[0;(bpv[1]+1)mod count bpv[0]]
638
```

## Part 2
There is no longer a need to maintain the entire buffer, so the `b` part of `bpv` is now a single
number. While the simulation would finish in a reasonable time, it is possible to optimize by taking
multiple steps at once, which cuts down more and more steps as the list gets longer.

As with part 1, we use an iterated function. This time it takes two fixed parameters, one for the
step size and one for the number of steps (which is also a parameter to the overall solution
function). It also takes a `bpv` parameter as an accumulator. The "buffer" is now initialized to the
null integer.
```q
q)step:3
q)n:50000000
q)bpv:(0N;0;1)
```
The workings of the function are best demonstrated using a later iteration:
```q
q)bpv:16 3 165
```
In the iterated function, we first check if we are finished by comparing the next value to the step
count. Because of the order of operations, the next value will actually be one higher than the step
count after the last step. We return the accumulator unchanged to stop the iteration.
```q
    if[bpv[2]=n+1;:bpv];
```
We find out how many steps to take before reaching the end of the list. We start by taking the
number of elements from the current position until the end of the buffer, then divide it by the step
size. We use `or` and `and` to clamp the value, ensuring that we take at least one step but we don't
take more than the total step count.
```q
q)bpv[2]-bpv[1]
162
q)(bpv[2]-bpv[1]) div step
54
q)1+n-bpv[2]
49999836
q)steps:(1+n-bpv[2]) and 1 or (bpv[2]-bpv[1]) div step
q)steps
54
```
We find the position after taking the given number of steps. Since each step includes an insertion,
the actual value to increase the position by is `step+1`, but we stop short of the insertion on the
last step, so we subtract one after the multiplication. Furthermore, the size of the buffer changes
due to the insertions, so the value we need to modulo by is `v+steps-1`.
```q
q)(step+1)*steps
216
q)-1+(step+1)*steps
215
q)bpv[1]+-1+(step+1)*steps
218
q)bpv[2]+steps-1
218
q)pos:(bpv[1]+-1+(step+1)*steps)mod bpv[2]+steps-1
q)pos
0
```
We check if the next position is zero, since that means we have to update the value in the
accumulator:
```q
    if[pos=0; ... ]
```
The value to put in is the one we get after doing the penultimate step in the sequence:
```q
q)bpv[0]:bpv[2]+steps-1
q)bpv
218 3 165
```
We update the position and next value in the accumulator, which completes the return value of the
iterated function:
```q
q)bpv[1]:pos+1
q)bpv[2]+:steps
q)bpv
218 1 219
```
We call the iterated function with `/` (over), using the overload that takes an iteration count and
an initial value of the accumulator:
```q
    bpv:{[step;n;bpv]
        ...
    bpv}[x;n]/[(0N;0;1)];
```
After the iteration, we have the final state:
```q
q)bpv
1222153 45669939 50000001
```
The answer is in the first element:
```q
q)bpv 0
1222153
```
