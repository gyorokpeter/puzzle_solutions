# Breakdown
## Part 1
Example input:
```q
x:"\n"vs"aaa: you hhh\nyou: bbb ccc\nbbb: ddd eee\nccc: ddd eee fff\nddd: ggg\neee: out"
x,:"\n"vs"fff: out\nggg: out\nhhh: ccc fff iii\niii: out"
```
We split the input on `": "`:
```q
q)a
"aaa" "you hhh"
"you" "bbb ccc"
"bbb" "ddd eee"
"ccc" "ddd eee fff"
"ddd" "ggg"
"eee" "out"
"fff" "out"
"ggg" "out"
"hhh" "ccc fff iii"
"iii" "out"
```
We create an adjacency map by using the first element as the key and the remaining elements as
value lists. We use symbols to make operations simpler.
```q
q)adj:(`$a[;0])!`$" "vs/:a[;1]
q)adj
aaa| `you`hhh
you| `bbb`ccc
bbb| `ddd`eee
ccc| `ddd`eee`fff
ddd| ,`ggg
eee| ,`out
fff| ,`out
ggg| ,`out
hhh| `ccc`fff`iii
iii| ,`out
```
We find the number of paths via BFS. We initialize a goal counter to zero:
```q
q)goal:0
```
The queue starts with the `you` node with a multiplicity of 1:
```q
q)queue:([]n:enlist`you;c:1)
q)queue
n   c
-----
you 1
```
We iterate until the queue is empty. It is expected that we eventually run out of nodes.
```q
    while[count queue;
        ...
    ];
```
In the iteration, we expand the nodes in the queue by looking up the node labels in the adjacency
map and ungrouping them:
```q
q)update nn:adj n from queue
n   c nn
-------------
you 1 bbb ccc
q)nxts:ungroup update nn:adj n from queue
q)nxts
n   c nn
---------
you 1 bbb
you 1 ccc
```
We add the multiplicities of any `out` nodes to the goal counter:
```q
q)goal+:exec sum c from nxts where nn=`out
q)goal
0
```
We create the next queue by summing the multiplicities by node label:
```q
q)queue:0!select sum c by n:nn from nxts
q)queue
n   c
-----
bbb 1
ccc 1
```
The code for the iteration ends here.

After the iteration, the `goal` variable contains the total number of paths.
```q
q)goal
5
```

## Part 2
Example input:
```q
x:"\n"vs"svr: aaa bbb\naaa: fft\nfft: ccc\nbbb: tty\ntty: ccc\nccc: ddd eee\nddd: hub"
x,:"\n"vs"hub: fff\neee: dac\ndac: fff\nfff: ggg hhh\nggg: out\nhhh: out"

```

The initialization is the same as in part 1.
```q
q)a:": "vs/:x
q)adj:(`$a[;0])!`$" "vs/:a[;1]
q)goal:0
```
The queue now starts at the `svr` node and has two additional columns, `fft` and `dac`, which start
at 0 and get set to 1 when the path passes the node with the respective label.
```q
q)queue:([]n:enlist`svr;c:1;fft:0b;dac:0b)
q)queue
n   c fft dac
-------------
svr 1 0   0
```
In the BFS, when we expand the nodes, we make sure to update the `fft` and `dac` flags:
```q
q)nxts:update fft:fft or nn=`fft,dac:dac or nn=`dac from ungroup update nn:adj n from queue
q)nxts
n   c fft dac nn
-----------------
svr 1 0   0   aaa
svr 1 0   0   bbb
```
When adding the number of found paths to the goal counter, we only add them if both flags are set:
```q
q)goal+:exec sum c from nxts where nn=`out,fft,dac
```
When creating the next queue, we include the two flags in the group by. This way paths that pass
through those special nodes are tallied separately from those that don't.
```q
q)queue:0!select sum c by n:nn,fft,dac from nxts
q)queue
n   fft dac c
-------------
aaa 0   0   1
bbb 0   0   1
```
After the iteration, the `goal` variable contains the total number of paths.
```q
q)goal
2
```
