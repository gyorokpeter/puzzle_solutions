# Breakdown
Example input:
```q
x:"\n"vs"Monkey 0:\n  Starting items: 79, 98\n  Operation: new = old * 19\n  Test: divisible by 23\n    If true: throw to monkey 2\n    If false: throw to monkey 3\n";
x,:"\n"vs"Monkey 1:\n  Starting items: 54, 65, 75, 74\n  Operation: new = old + 6\n  Test: divisible by 19\n    If true: throw to monkey 2\n    If false: throw to monkey 0\n";
x,:"\n"vs"Monkey 2:\n  Starting items: 79, 60, 97\n  Operation: new = old * old\n  Test: divisible by 13\n    If true: throw to monkey 1\n    If false: throw to monkey 3\n";
x,:"\n"vs"Monkey 3:\n  Starting items: 74\n  Operation: new = old + 3\n  Test: divisible by 17\n    If true: throw to monkey 0\n    If false: throw to monkey 1";
```

## Common
The solution will take two parameters: `d` is the divisor (3 for Part 1 and 1 for Part 2), and `r` is the number of rounds (20 for Part 1 and 10000 for Part 2).

We break the input into sections and then on newlines within each section:
```q
a:"\n"vs/:"\n\n"vs"\n"sv x;
```
We extract the item numbers:
```q
q)it:"J"$4_/:" "vs/:a[;1]except\:",";
q)it
79 98
54 65 75 74
79 60 97
,74
```
We convert the item list into an index into a single list:
```q
q)its
79 98 54 65 75 74 79 60 97 74
q)itm:(0,-1_sums count each it)cut til count its;
q)itm
0 1
2 3 4 5
6 7 8
,9
```
We also generate the operations in the form of callable functions or projections:
```q
q)op0:6_/:" "vs/:a[;2];
q)op0
,"*" "19"
,"+" ,"6"
,"*" "old"
,"+" ,"3"
q)op:?[op0[;1]like"old";count[op0]#{x*x};(("*+"!(*;+))op0[;0;0])@'"J"$op0[;1]];
q)op
*[19]
+[6]
{x*x}
+[3]
```
We get the monkeys' individual moduli:
```q
q)dv:"J"$last each" "vs/:a[;3];
q)dv
23 19 13 17
```
And their throw destinations:
```q
q)throw:reverse each"J"$last each/:" "vs/:/:a[;4 5];
q)throw
3 2
0 2
3 1
1 0
```
Finally we cache the product of the moduli (technically this should be the least common multiple, but it's the same as the numbers are primes):
```q
q)pdv:prd dv;
q)pdv
96577
```
We initialize a _state_ using the initial items:
```q
q)st:(itm;its;count[it]#0);
q)st
(0 1;2 3 4 5;6 7 8;,9)
79 98 54 65 75 74 79 60 97 74
0 0 0 0
```
During each **step** we perform the following operations:

We extract the individual variables from the state:
```q
itm:st 0;its:st 1;tc:st 2;
```
We look up the indices of the items to be thrown by the current monkey:
```q
ii:itm i;
```
We increment the throw counter for the monkey, which is required for calculating the final answer:
```q
tc[i]+:count ii;
```
We calculate the new weights of the items by applying the monkey's operation, performing the division (for part 1 only) and modulo by the product of the monkeys' numbers:
```q
w:((op[i]@'its ii)div d)mod pdv;
```
We update the weights in the array:
```q
its[ii]:w;
```
We append the items to the monkey they are thrown to. For this purpose we generate the target index by indexing the monkey's destination array by the truth value of its divisibility condition, then finally do the update with an iterated amend as this is the best way to modify multiple indices in a sequence:
```q
itm:@[;;,;]/[itm;throw[i]0=w mod dv[i];ii];
```
We also clear out the current monkey's inventory:
```q
itm[i]:"j"$();
```
Finally we pack the state back together to return for the following iteration:
```q
(itm;its;tc)
```
This is just one step of a round, the full round consists of calling the step for each monkey in turn:
```q
round:step/[;til count itm];
```
To get the final state, we iterate the round function for the required number of rounds:
```q
mb:last round/[r;st];
```
The last element of the state was the throw counts. To get the answer from this, we put it in descending order and take the product of the top two elements.
```q
prd 2#desc mb
```
