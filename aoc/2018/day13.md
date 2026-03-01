# Breakdown
Example input:
```q
x:"\n"vs"/->-\\\n|   |  /----\\\n| /-+--+-\\  |\n| | |  | v  |\n\\-+-/  \\-+--/\n  \\------/   "
```
Because backslashes have special meaning in strings, we have to be careful to escape every backslash
that appears in the input. But this only applies to manually creating the input - reading it using
`read0` will process files containing backslashes correctly.

## Common
Both parts are solved by the same function. It takes an additional parameter for the part.

We find the cart positions using a [2D search](../utils/patterns.md#2d-search):
```q
q)cartPos:raze til[count x],/:'where each x in "^v><"
q)cartPos
0 2
3 9
```
We find the cart directions by indexing into the map:
```q
q)x ./:cartPos
">v"
```
We initialize a table with the states of the carts. This includes the position, direction and last
turn:
```q
q)carts:([]pos:cartPos;dir:cartDir;turn:-1)
q)carts
pos dir turn
------------
0 2 >   -1
3 9 v   -1
```
We generate a map with the cart positions updated with the respective track sectins. We take
advantage of the `^` (fill) operator which allows "painting over" certain elements of a list or
matrix.
```q
q)("^v><"!"||--")x
"  -  "
"             "
"             "
"         |   "
"             "
"             "
q)map:x^("^v><"!"||--")x
q)map
"/---\\"
"|   |  /----\\"
"| /-+--+-\\  |"
"| | |  | |  |"
"\\-+-/  \\-+--/"
"  \\------/   "
```
We perform an iteration. It hsa no specific end condition, but there is a return statement in the
middle.
```q
    while[1b;
        ...
    ];
```
In the iteration, we initialize a counter for the current cart:
```q
q)cart:0
```
We also resort the carts table in ascending order. This performs a lexicographic sort, which is
exactly the correct behavior here for top-to-bottom movement.
```q
q)carts:`pos xasc carts
q)carts
pos dir turn
------------
0 2 >   -1
3 9 v   -1
```
We perform a nested iteration over the carts:
```q
    while[cart<count carts;
        ...
    ];
```
In the nested iteration, we calculate the next position of the current cart by adding a delta
corresponding to the cart's direction:
```q
q)newPos:carts[cart;`pos]+("^v><"!(-1 0;1 0;0 1;0 -1))carts[cart;`dir]
q)newPos
0 3
```
We initialze a continuation flag. This is necessary because we are going to check if the current
cart needs to be deleted, and if it does, we should not run the rest of the iteration code.
```q
q)cont:1b
```
We check if there are any carts in the new position of the current cart:
```q
    if[0<count ni:exec i from carts where pos~\:newPos;
        ...
    ];
```
If there is, we perform a few specific actions.

If we are in part 1, we rethrn here. The return value is the coordinates converted into a string,
joined with `","`. The coordinates are zero-based so no need to offset them, but they do need to be
reversed:
```q
    if[part=1; :","sv string reverse newPos]
```
Otherwise, we set the continuation flag to false and delete both carts from the table:
```q
    cont:0b;
    carts:delete from carts where i in (ni,cart);
```
We also check if the deleted cart was earlier in the table than the current cart, in which case the
deletion of two rows would cause the `cart` variable to skip over one cart. We have to compensate by
decrementing the variable.
```q
    if[cart>first ni; cart-:1];
```
The code for the crash check ends here.

The rest of the iteration code only needs to run if there was no crash:
```q
    if[cont;
        ...
    ];
```
We update the position of the current cart in the table:
```q
q)carts[cart;`pos]:newPos
q)carts
pos dir turn
------------
0 3 >   -1
3 9 v   -1
```
To find the next direction of the cart, first we get the tile type under the new position:
```q
q)tile:map . newPos
q)tile
"-"
```
We also get the cart's current direction:
```q
q)dir:carts[cart;`dir]
q)dir
">"
```
We perform a four-way check for the various tile types to determine the next direction:
```q
    carts[cart;`dir]:$[
        ...
        '"unknown tile: ",tile
    ];
```
The easiest are the tiles `"-|"`, which simply keep the current direction:
```q
    tile in "-|"; dir
```
For the corner tiles, we use dictionaries to map the current direction to the next:
```q
    tile="\\"; ("^>v<"!"<v>^")dir;
    tile="/"; ("^>v<"!">^<v")dir;
```
Finally, for a crossing, we update the `turn` field of the cart's record, wrapping around at 3
(using -1 as the starting value means the first increment will result in zero, so zero should mean
turning left). Then we use the current value of this filed to decide whether to turn (like the
corners) or not (which is represented by the identity function `::`).
```q
    tile="+"; [t:carts[cart;`turn]:(carts[cart;`turn]+1)mod 3;
        (("^>v<"!"<^>v");::;("^>v<"!">v<^"))[t]dir
    ];
```
After assigning the direction, we increment the `cart` variable:
```q
q)cart+:1
q)cart
1
```
The end of the nested iteration ends here.

There is one final step that is part of the main iteration: if there are less than 2 carts left, we
return the position of the only remaining cart, which is the answer to part 2.
```q
    if[2>count carts;
        :","sv string reverse exec first pos from carts;
    ];
```

## Part 1
We call the common function, passing in 1 for the part.
```q
q)d13common[1;x]
"7,3"
```

## Part 2
Example input:
```q
x:"\n"vs"/>-<\\  \n|   |  \n| /<+-\\\n| | | v\n\\>+</ |\n  |   ^\n  \\<->/"
```
We call the common function, passing in 2 for the part.
```q
q)d13common[2;x]
"6,4"
```
