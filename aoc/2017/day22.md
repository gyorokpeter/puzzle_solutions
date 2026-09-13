# Breakdown
Example input:
```q
x:"\n"vs"..#\n#..\n..."
```

## Common
The common function takes three parameters: the rules dictionary, the step count and the map.
```q
q)step:10000
```
The rules dictionary tells what to do depending on what is under the current position: the updated
contents of the map and the direction delta. For example, this is the rule dictionary for part 1:
```q
q)rules:".#"!(("#";-1);(".";1))
q)rules
.| "#" -1
#| "." 1
```
We perform the updates to the map in an iterated function. The function takes a bound parameter for
`rules` and an accumulator that contains four values: the map, the current position, direction and
the total number of nodes that became infected. We must pack the values into a list because q's
built-in iterators only support a single parameter to be the accumulator.
```q
q)map:x
q)pos:2#count[map]div 2
q)dir:0
q)total:0
q)x:(map;pos;dir;total)
q)x
("..#";"#..";"...")
1 1
0
0
```
Inside the iterated function, we start by unpacking the values from the accumulator:
```q
q)map:x 0;pos:x 1;dir:x 2;total:x 3
```
We need to check if the current position is within the bounds of the map. If not, we need to add an
extra empty row or column, and if the position is off the left or top of the map, we also shift it
to remain accurate after the addition.

If the current position is off the top of the map, we add a row of `"."` characters at the top and
shift the position down by 1:
```q
    if[pos[0]=-1; pos[0]:0; map:(enlist count[first map]#"."),map];
```
If the current position is off the left of the map, we add a column of `"."` characters at the left
and shift the position right by 1:
```q
    if[pos[1]=-1; pos[1]:0; map:".",/:map];
```
If the current position is off the bottom of the map, we add a row of `"."` characters at the
bottom:
```q
    if[pos[0]>=count map; map:map,(enlist count[first map]#".")];
```
If the current position is off the right of the map, we add a row of `"."` characters at the
right:
```q
    if[pos[1]>=count first map; map:map,\:"."];
```
We pick the rule that is in effect for the current position:
```q
q)map . pos
"."
q)rule:rules map . pos
q)rule
"#"
-1
```
We apply the direction delta, making sure to wrap around:
```q
q)dir:(dir+rule 1)mod 4
q)dir
3
```
We update the map at the current position based on the rule:
```q
q)map[pos 0;pos 1]:rule 0
q)map
"..#"
"##."
"..."
```
We update the total if the rule called for infecting the position:
```q
q)total+:"#"=rule 0
q)total
1
```
We update the position by adding the direction delta for the current direction:
```q
q)pos+:(-1 0;0 1;1 0;0 -1)dir
q)pos
1 0
```
Finally, we pack the variables into a list to form the new accumulator:
```q
q)(map;pos;dir;total)
("..#";"##.";"...")
1 0
3
1
```
This is the return value of the iterated function.

We call the iterated function using the overload of `/` (over) that takes a unary function, a step
count and an initial value:
```q
    mpdt:{[rules;x]
        ...
    }[rules]/[step;(map;2#count[map]div 2;0;0)];
```
After the iteration, we have the final state of the accumulator, and the last element is the answer.
```q
5475
q)mpdt
("....##..##..##....................................................................................
190 193
2
5587
q)last mpdt
5587
```

## Part 1
We call the common function with the rule dictionary and step count appropriate for part 1:
```q
q)rules:".#"!(("#";-1);(".";1));step:10000;d22[rules;step;x]
5587
```

## Part 2
We call the common function with the rule dictionary and step count appropriate for part 2. Note
that since this problem is "embarrassingly sequential", this will take a long time to run.
```q
q)rules:".W#F"!(("W";-1);("#";0);("F";1);(".";2));step:10000000;d22[rules;step;x]
2511944
```
