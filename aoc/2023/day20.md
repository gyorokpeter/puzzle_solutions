# Overview
The solution relies on the shape of the graph described by the input, therefore it is not applicable to the example input for part 2.

A sequence of flip-flops forms a counter. Sending a low pulse flips the least significant digit, and if it was a 1 (high), it emits a low pulse to the next flip-flop, as if performing carry during addition. Once a digit changes from 0 to 1, the pulse is ignored by the next flip-flop.

In the real input we have the broadcaster connected to 4 separate 12-bit counters. Each of them has an associated conjunction node that is wired to specific bits, such that it fires if the counter contains a particular number. When this happens, it maxes out the counter and resets it, and simultaneously triggers an inverter. The four inverters are connected to a single conjunction node that only fires if the inverters fire simultaneously. Since each of the counters has a different cycle, we need to find the cycle lengths and calculate when the cycles coincide.

It is useful to visualize the graph using Graphviz as it makes the graph structure very obvious.

# Breakdown

Example input:
```q
x:"\n"vs"broadcaster -> a, b, c\n%a -> b\n%b -> c\n%c -> inv\n&inv -> a";
```

## Common
The solution for the two parts is shared, the function takes an explicit `part` parameter in addition to the input. The bits specific to part 2 can't be demonstrated on the example input.

We split the lines and make a connectivity map:
```q
q)p
"broadcaster" "a, b, c"
"%a"          ,"b"
"%b"          ,"c"
"%c"          "inv"
"&inv"        ,"a"
q)conn:(`$p[;0]except\:"%&")!`$", "vs/:p[;1];
q)conn
broadcaster| `a`b`c
a          | ,`b
b          | ,`c
c          | ,`inv
inv        | ,`a
```
We also make a map of the node types, giving the broadcaster the node type `"="`:
```q
q)nt:key[conn]!p[;0][;0]
q)nt[`broadcaster]:"="
q)nt
broadcaster| =
a          | %
b          | %
c          | %
inv        | &
```
For visualizing with Graphviz, the following can be used:
```q
q)-1 "digraph G {\n",raze[{"    \"",nt[x`s],string[x`s],"\" -> \"",nt[x`t],string[x`t],"\"\n"}each ungroup([]s:key conn;t:value conn)],"}"
digraph G {
    "=broadcaster" -> "%a"
    "=broadcaster" -> "%b"
    "=broadcaster" -> "%c"
    "%a" -> "%b"
    "%b" -> "%c"
    "%c" -> "&inv"
    "&inv" -> "%a"
}
```
We initialize some variables to store the state during the simulation. For conjunction nodes we need to maintain the wire states:
```q
q)wire0:select from ungroup([]s:key conn;t:value conn;signal:0b) where nt[t]="&";
q)
q)wire0
s t   signal
------------
c inv 0
```
For flip-flop nodes we need to maintain the node state:
```q
q)wire1:select from ([]s:`;t:key conn;signal:0b) where nt[t]="%";
q)wire1
s t signal
----------
  a 0
  b 0
  c 0
```
The two can go into the same table, with the flip-flop "wires" having no source:
```q
q)wire
s t  | signal
-----| ------
c inv| 0
  a  | 0
  b  | 0
  c  | 0
```
we also initialize a low and high signal counter (for part 1) and a step counter (for part 2):
```q
tl:th:0; step:0;
```
For part 2 we do some digging to find specific nodes. We find the conjunction node leading into the `rx` node:
```q
fin:first where`rx in/:conn
```
We also find all nodes that connect to this node - these are the inverters coming from the counter conjunctions (there are 4 of them but we don't rely on this number):
```q
fins:where fin in/:conn
```
We also initialize a cycle map:
```q
cycle:fins!count[fins]#enlist();
```
Next is the actual simulation. We run for 1000 steps for part 1 and 10000 steps for part 2 (the maximum cycle length is 4096 so this ensures at least 2 cycles).
```q
do[$[part=1;1000;10000]; ... ]
```
We increment the step counter:
```q
step+:1
```
We initialize a queue with the signal from the broadcaster:
```q
queue:enlist(`;`broadcaster;0b)
```
The queue is processed in an inner loop. In this case we can't use a BFS since each signal must be fully processed before processing the next one and the states of the wires may change in the middle of processing the queue. Therefore we are left with the slow push-pull model.
```q
while[count queue; ... ]
```
We pop the first element from the queue:
```q
curr:first queue;
queue:1_queue
```
We increment either the high or low signal counter depending on the value of the current signal:
```q
$[curr 2;th+:1;tl+:1]
```
We assign names to the current node, current node type and current signal for easier reference:
```q
cn:curr 1; cnt:nt cn; cs:curr 2
```
We generate the list of next wires using the connectivity map:
```q
nw:cn,/:conn cn
```
Depending on the node type, we do one of 3 things. If the node is a broadcaster, we don't change the signal:
```q
ns:$[cnt="=";cs; ...
```
If it is a flip-flop, we further branch on the current signal. If it is high, we swallow the signal, indicated by `(::)`. If it is a low signal, we invert the state in the `wire` map and change the signal to the new value of the wire:
```q
... cnt="%";$[cs;::;[wire[(`;cn)]:not wire(`;cn);wire[(`;cn);`signal]]]; ...
```
If it is a conjunction, we update the `wire` with the new signal and change the signal to the output of the conjunction (NAND operation):
```q
... cnt="&";[wire[(curr[0];cn)]:cs;not all exec signal from wire where t=cn]; ...
```
For any other node type, we swallow the signal (this never happens but we should always have a default case).
```q
... (::)];
```
If we are in part 2, we check if the target of the signal is one of the four inverters, and if so, we append the current step number to the node's `cycle` entry:
```q
if[part=2; if[cn in fins; if[ns; cycle[cn],:step]]]
```
Finally, if the signal was not swallowed, we put it in the queue for all the outgoing wires:
```q
if[not(::)~ns; queue,:nw,\:ns];
```
At the end of the iteration, if we are in part 1, we return the product of the low and high signal counters:
```q
:th*tl
```
Otherwise we are in part 2. Since we did 10000 steps, the `cycle` map should now have at least 2 elements for each of the four inverters. Using `deltas` on these should return the same number twice, since the first element is compared to zero and the second one is compared to the first:
```q
cl:distinct each deltas each value cycle
```
So `cl` is a list of single-element lists. We can raze them and take their product:
```q
prd raze cl
```
Just like day 8, the cycle lengths are primes, so no need to use LCM, simple product works well.
