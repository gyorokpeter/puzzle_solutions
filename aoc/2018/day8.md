# Breakdown
Example input:
```q
x:enlist "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
```

## Common
We use a helper function (`d8prep`) to build the tree.

We first cut the input and convert it into integers:
```q
q)n:"J"$" "vs first x
q)n
2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
```
The tree is built up using a recursive function. It takes a single argument that is a pair of the
remaining numbers to parse and the last node parsed (which is ignored). It returns a data structure
of the same type after parsing a node at the beginning of the number list.

We extract the first number that indicates the child count:
```q
    c:np[0][0]
```
We extract the second number that indicates the metadata count:
```q
    m:np[0][1]
```
We check if the node has zero child nodes. If so, we return the number list with the correct number
of elements (two plus the metadata count) dropped, and a node with an empty child list and the
correct number of metadata entries:
```q
    if[0=c;
        res:((2+m)_np 0;(();m#2_np 0));
        :res
    ];
```
Otherwise, we call the function recursively. We use a version of the `\` (scan) iterator that takes
a repetition count and an initial value. This is the reason for the choice of the parameter
structure - it has to have all elements stuffed in such that the function takes one parameter, which
contributes to which overload of `\` is selected, and the presence of the last node as a parameter
that is actually ignored is just there because `\` uses it as an accumulator, and we can collect the
intermediate values into a list. The first element is the initial state, which is meaningless as it
contains no "last node".
```q
    rs:1_.z.s\[c;(2_np[0];())]
```
For the return value, we take the remaining numbers from the last iteration and drop the metadata
entries, and put the child nodes and metadata entries in the "last node" value.
```q
    res:(m _last[rs][0];(rs[;1];m#last[rs][0]))
```
We invoke this function with the whole list of numbers and an empty list as the last node. The
return value includes the now-empty number list, so we take only the last value.
```q
    tree:-1#{[np]
        ...
    }[(n;())];
```
The result is the tree in a nested list format:
```q
q)tree
((();10 11 12);(,(();,99);,2)) 1 1 2
```

## Part 1
We use the helper function to generate the tree:
```q
q)tree:d8prep x
q)tree
((();10 11 12);(,(();,99);,2)) 1 1 2
```
The sum of metadata entries can be obtained using a recursive function. This function sums the
metadata entries in the current node and adds the results of recursively calculating the sums for
the child nodes.
```q
q)sum{sum last[x],raze .z.s each first x}each tree
138
```

## Part 2
We use the helper function to generate the tree:
```q
q)tree:d8prep x
q)tree
((();10 11 12);(,(();,99);,2)) 1 1 2
```
The value of the tree can be obtained using a recursive function. We need to make a choice based on
whether the count of the child nodes is zero:
```q
    $[0=count first x;
        ...
    ]
```
If it is, we sum the metadata entries, but prepending a zero to make sure to get the correct type
for the result in case there are no entries:
```q
    sum 0,last x
```
If there are child nodes, we recursively evaluate the child nodes after indexing them with the
metadata values:
```q
    sum 0,.z.s each first[x][-1+last x]
```
Putting it all together:
```q
q)sum{$[0=count first x;sum 0,last x;sum 0,.z.s each first[x][-1+last x]]}each tree
66
```
