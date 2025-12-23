# Breakdown

## Part 1
Example input:
```q
x:"\n"vs"COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN"
```
We split the lines on the unusual separator character `")"`:
```q
q)")"vs/:x
"COM" ,"B"
,"B"  ,"C"
,"C"  ,"D"
,"D"  ,"E"
,"E"  ,"F"
,"B"  ,"G"
,"G"  ,"H"
,"D"  ,"I"
,"E"  ,"J"
,"J"  ,"K"
,"K"  ,"L"
,"K"  "YOU"
,"I"  "SAN"
```
This time we convert the values to symbols for easier comparison:
```q
q)`$")"vs/:x
COM B
B   C
C   D
D   E
E   F
B   G
G   H
D   I
E   J
J   K
K   L
K   YOU
I   SAN
```
Then we put the input in a table. The below is a q idiom based on the internal representation of
tables. We first have to flip the rows such that we have a list with the table columns as elements,
then make a dictionary where the column names are the keys, then finally flip again to turn it into
a table. This second flip doesn't rearrange the items, only the display.
```q
q)st:flip`s`t!flip`$")"vs/:x
q)st
s   t
-------
COM B
B   C
C   D
D   E
E   F
B   G
G   H
D   I
E   J
J   K
K   L
K   YOU
I   SAN
```
The puzzle is asking us to find the total number of paths in the graph in a single direction. First
we can make a dictionary that maps each node to its children:
```q
q)childMap:exec t by s from st
q)childMap
B  | `C`G
C  | ,`D
COM| ,`B
D  | `E`I
E  | `F`J
G  | ,`H
I  | ,`SAN
J  | ,`K
K  | `L`YOU
```
(In q we don't have to aggregate if we group by something, we simply get every value in the group as
a list. And we use `exec` to get a dictionary instead of a table.) To get the number of paths, we
need the transitive closure of the child map. In the final map, every node will be mapped to all
nodes that can be reached from it, so every such node pairing will correspond to one path. To
generate the transitive closure, all we have to do is repeatedly apply the child map to itself and
concatenate the resulting nodes to the exiting ones, dropping any duplicates. We do this until there
are no more paths generated. This "repeat until no change" behavior can be achieved using the `/`
(over) iterator.
One iteration would look like this:
```q
q)x:childMap
q)x x
B  | (,`D;,`H)
C  | ,`E`I
COM| ,`C`G
D  | (`F`J;,`SAN)
E  | (`symbol$();,`K)
G  | ,`symbol$()
I  | ,`symbol$()
J  | ,`L`YOU
K  | (`symbol$();`symbol$())
```
Notice how each element on the right has been replaced by its children. Now we concatenate the
already known children to the existing ones:
```q
q)x,'x x
B  | (`C;`G;,`D;,`H)
C  | (`D;`E`I)
COM| (`B;`C`G)
D  | (`E;`I;`F`J;,`SAN)
E  | (`F;`J;`symbol$();,`K)
G  | (`H;`symbol$())
I  | (`SAN;`symbol$())
J  | (`K;`L`YOU)
K  | (`L;`YOU;`symbol$();`symbol$())
```
Then we raze each list on the right such that the elements are on the same level. We also use
distinct on them, although this doesn't change anything on the first iteration, it will on
subsequent iterations as there will be duplicates.
```q
q)distinct each raze each x,'x x
B  | `C`G`D`H
C  | `D`E`I
COM| `B`C`G
D  | `E`I`F`J`SAN
E  | `F`J`K
G  | ,`H
I  | ,`SAN
J  | `K`L`YOU
K  | `L`YOU
```
Putting this together, the transitive closure calculation looks like:
```q
q)childMap:{distinct each raze each x,'x x}/[childMap]
q)childMap
B  | `C`G`D`H`E`I`F`J`SAN`K`L`YOU
C  | `D`E`I`F`J`SAN`K`L`YOU
COM| `B`C`G`D`H`E`I`F`J`SAN`K`L`YOU
D  | `E`I`F`J`SAN`K`L`YOU
E  | `F`J`K`L`YOU
G  | ,`H
I  | ,`SAN
J  | `K`L`YOU
K  | `L`YOU
```
The answer to part 1 is the total count of the elements on the right side:
```q
q)sum count each childMap
54
```
(This is not the result in the puzzle because the example input was that for part 2).

## Part 2
We create the `st` table like above.

Now we create a mapping from child to parent:
```q
q)parent:exec t!s from st
q)parent
B  | COM
C  | B
D  | C
E  | D
F  | E
G  | B
H  | G
I  | D
J  | E
K  | J
L  | K
YOU| K
SAN| I
```
We can use this map to trace a path from any node to the root. We start at a node (`YOU` or `SAN`)
and repeatedly apply the map to the current node, advancing one level up. Once again we want to
"repeat until no change" - once we are at the root node (`COM`), the next level up will be the empty
symbol, and the next level up from there will be once again the empty symbol, thus "no change". This
illustrates how powerful q's concept of "application" is - previously we iteratively applied a
function, now we will similarly iteratively apply a dictionary. However we also need the full path
this time, so we use `\` (scan) instead of `/` (over). These two iterators perform the exact same
calculations, the only difference is that `\` returns the "audit trail" while `/` only returns the
final value.
```q
q)youPath:parent\[`YOU]
q)youPath
`YOU`K`J`E`D`C`B`COM`
q)sanPath:parent\[`SAN]
q)sanPath
`SAN`I`D`C`B`COM`
```
Notice the backticks at the end which are the empty symbols. The answer is the count of the
symmetric difference of these two paths. We also need to subtract 1 per path since we are counting
transitions, not nodes.
```q
q)youPath except sanPath
`YOU`K`J`E
q)sanPath except youPath
`SAN`I
q)(count[youPath except sanPath]-1)+(count[sanPath except youPath]-1)
4
```
