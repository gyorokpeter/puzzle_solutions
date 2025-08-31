# Breakdown
For this day, actually figuring out what is being asked for is probably more difficult than
actually implementing it.

Example input:
```q
x:();
x,:enlist"mxmxvkd kfcds sqjhc nhms (contains dairy, fish)"
x,:enlist"trh fvjkl sbzzf mxmxvkd (contains dairy)"
x,:enlist"sqjhc fvjkl (contains soy)"
x,:enlist"sqjhc mxmxvkd sbzzf (contains fish)"
```

## Common
We parse the input into a table with two columns, `ing` and `al` (ingredients and allergens).
Both are symbol lists.
```q
q)t:{`$([]ing:" "vs/:x[;0];al:", "vs/:-1_/:x[;1])}" (contains "vs/:x
q)t
ing                       al
-------------------------------------
`mxmxvkd`kfcds`sqjhc`nhms `dairy`fish
`trh`fvjkl`sbzzf`mxmxvkd  ,`dairy
`sqjhc`fvjkl              ,`soy
`sqjhc`mxmxvkd`sbzzf      ,`fish
```
We "ungroup" the table on the `al` column. The built-in `ungroup` function can't do this (since it
assumes that all list columns should be ungrouped in parallel) so it must be done by explicitly
writing out the operation.
```q
q)poss:raze exec ing{`ing`al!(x;y)}/:'al from t
q)poss
ing                       al
-------------------------------
`mxmxvkd`kfcds`sqjhc`nhms dairy
`mxmxvkd`kfcds`sqjhc`nhms fish
`trh`fvjkl`sbzzf`mxmxvkd  dairy
`sqjhc`fvjkl              soy
`sqjhc`mxmxvkd`sbzzf      fish
```
Then we find out the intersection of ingredients for each allergen.
```q
q)poss2:select inter/[ing] by al from poss
q)poss2
al   | ing
-----| --------------
dairy| ,`mxmxvkd
fish | `mxmxvkd`sqjhc
soy  | `sqjhc`fvjkl
```

## Part 1
We take all the ingredients from the `poss2` table and subtract them from the ingredients in the
initial table, then count the result.
```q
q)raze[t`ing] except (exec raze ing from poss2)
`kfcds`nhms`trh`sbzzf`sbzzf
q)count raze[t`ing] except (exec raze ing from poss2)
5
```

## Part 2
We use an iterative method to figure out which allergen maps to which ingredient. We check which
elements in `poss2` have only one element. These can be added to the map, the corresponding lines
removed from `poss2` and the known ingredients removed from the other rows as well, which will leave
other allergens unambiguous for the next iteration.

We initialize the allergen map to an empty table:
```q
q)ingm:([al:`$()]ing:`$())
```
The iteration lasts as long as there are items in the `poss2` table:
```q
    while[0<count poss2;
        ...
    ];
```
We find the rows in `poss2` that have only one ingredient and we add them to the map:
```q
q)select from poss2 where 1=count each ing
al   | ing
-----| -------
dairy| mxmxvkd
q)select al, first each ing from poss2 where 1=count each ing
al    ing
-------------
dairy mxmxvkd
q)ingm,:select al, first each ing from poss2 where 1=count each ing
q)ingm
al   | ing
-----| -------
dairy| mxmxvkd
```
We drop the rows from `poss2` where we have already mapped the allergen:
```q
q)poss2
al   | ing
-----| --------------
dairy| ,`mxmxvkd
fish | `mxmxvkd`sqjhc
soy  | `sqjhc`fvjkl
q)poss2:key[ingm]_poss2
q)poss2
al  | ing
----| -------------
fish| mxmxvkd sqjhc
soy | sqjhc   fvjkl
```
We also remove all the ingredients with known allergens:
```q
q)poss2:update ing:ing except\:(exec ing from ingm) from poss2
q)poss2
al  | ing
----| ------------
fish| ,`sqjhc
soy | `sqjhc`fvjkl
```
The iteration continues from here.

After the iteration we end up with a full allergen map:
```q
q)ingm
al   | ing
-----| -------
dairy| mxmxvkd
fish | sqjhc
soy  | fvjkl
```
We sort by allergen name, then turn the ingredients back to strings and join them with commas:
```q
q)exec ","sv string ing from`al xasc ingm
"mxmxvkd,sqjhc,fvjkl"
```
