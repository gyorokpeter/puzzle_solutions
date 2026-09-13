# Breakdown
Example input:
```q
x:();
x,:enlist"../.# => ##./#../..."
x,:enlist".#./..#/### => #..#/..../..../#..#"
```

## Common
The common function takes two parameters: the step count and the puzzle input.

```q
q)step:20
```
We initialize the grid with the starting pattern:
```q
q)pattern:(".#.";"..#";"###")
q)pattern
".#."
"..#"
"###"
```
We split the rules on `" => "`, then split each element on `"/"`:
```q
q)" => "vs/:x
"../.#"       "##./#../..."
".#./..#/###" "#..#/..../..../#..#"
q)rawrule:"/"vs/:/:" => "vs/:x
q)rawrule
("..";".#")         ("##.";"#..";"...")
(".#.";"..#";"###") ("#..#";"....";"....";"#..#")
```
We generate the full set of rules by rotating and flipping the pattern side (see below for details).
```q
q)raze .d21.rotate each rawrule
("..";".#")         ("##.";"#..";"...")
(".#";"..")         ("##.";"#..";"...")
("..";"#.")         ("##.";"#..";"...")
("#.";"..")         ("##.";"#..";"...")
("..";".#")         ("##.";"#..";"...")
(".#";"..")         ("##.";"#..";"...")
("..";"#.")         ("##.";"#..";"...")
("#.";"..")         ("##.";"#..";"...")
(".#.";"..#";"###") ("#..#";"....";"....";"#..#")
("###";"..#";".#.") ("#..#";"....";"....";"#..#")
(".#.";"#..";"###") ("#..#";"....";"....";"#..#")
("###";"#..";".#.") ("#..#";"....";"....";"#..#")
("..#";"#.#";".##") ("#..#";"....";"....";"#..#")
(".##";"#.#";"..#") ("#..#";"....";"....";"#..#")
("#..";"#.#";"##.") ("#..#";"....";"....";"#..#")
("##.";"#.#";"#..") ("#..#";"....";"....";"#..#")
```
Since there might be duplicates, we use `distinct` to filter them out. We also convert the result
into a dictionary.
```q
q)distinct raze .d21.rotate each rawrule
("..";".#")         ("##.";"#..";"...")
(".#";"..")         ("##.";"#..";"...")
("..";"#.")         ("##.";"#..";"...")
("#.";"..")         ("##.";"#..";"...")
(".#.";"..#";"###") ("#..#";"....";"....";"#..#")
("###";"..#";".#.") ("#..#";"....";"....";"#..#")
(".#.";"#..";"###") ("#..#";"....";"....";"#..#")
("###";"#..";".#.") ("#..#";"....";"....";"#..#")
("..#";"#.#";".##") ("#..#";"....";"....";"#..#")
(".##";"#.#";"..#") ("#..#";"....";"....";"#..#")
("#..";"#.#";"##.") ("#..#";"....";"....";"#..#")
("##.";"#.#";"#..") ("#..#";"....";"....";"#..#")
q)rule:{x[;0]!x[;1]}distinct raze .d21.rotate each rawrule
q)rule
("..";".#")        | ("##.";"#..";"...")
(".#";"..")        | ("##.";"#..";"...")
("..";"#.")        | ("##.";"#..";"...")
("#.";"..")        | ("##.";"#..";"...")
(".#.";"..#";"###")| ("#..#";"....";"....";"#..#")
("###";"..#";".#.")| ("#..#";"....";"....";"#..#")
(".#.";"#..";"###")| ("#..#";"....";"....";"#..#")
("###";"#..";".#.")| ("#..#";"....";"....";"#..#")
("..#";"#.#";".##")| ("#..#";"....";"....";"#..#")
(".##";"#.#";"..#")| ("#..#";"....";"....";"#..#")
("#..";"#.#";"##.")| ("#..#";"....";"....";"#..#")
("##.";"#.#";"#..")| ("#..#";"....";"....";"#..#")
```
We calculate the final state using the `/` (over) iterator with a step count and initial value (see
below for details on the iterated function):
```q
q)pattern:.d21.advance[rule]/[step;pattern]
q)pattern
"##.##."
"#..#.."
"......"
"##.##."
"#..#.."
"......"
```
We return the answer by comparing the elements to `"#"` and summing the result:
```q
q)sum sum pattern="#"
12i
```

## .d21.rotate
This function generates all the possible flips and rotations of a rule.
```q
q)ruleline:rawrule 1
q)ruleline
(".#.";"..#";"###")
("#..#";"....";"....";"#..#")
q)k:ruleline[0]; v:ruleline[1]; fk:flip k; rk:reverse k; rfk:reverse fk;
q)fk
"..#"
"#.#"
".##"
q)rk
"###"
"..#"
".#."
q)rfk
".##"
"#.#"
"..#"
```
The result is obtained by pairing all of the possible left sides with the same right side. The
syntax `(;)` is used here, which is simply a projection of `enlist`, creating two-element lists of
its arguments.
```q
q)(k;rk;reverse each k;reverse each rk;fk;rfk;reverse each fk;reverse each rfk)(;)\:v
(".#.";"..#";"###") ("#..#";"....";"....";"#..#")
("###";"..#";".#.") ("#..#";"....";"....";"#..#")
(".#.";"#..";"###") ("#..#";"....";"....";"#..#")
("###";"#..";".#.") ("#..#";"....";"....";"#..#")
("..#";"#.#";".##") ("#..#";"....";"....";"#..#")
(".##";"#.#";"..#") ("#..#";"....";"....";"#..#")
("#..";"#.#";"##.") ("#..#";"....";"....";"#..#")
("##.";"#.#";"#..") ("#..#";"....";"....";"#..#")
```

## .d21.break
This function breaks a pattern into chunks of a given size.
```q
q)pattern:("##..##";"..####";"..###.";"......";".###..";"....##")
q)size:2
q)size cut pattern
"##..##" "..####"
"..###." "......"
".###.." "....##"
q)size cut/:/:size cut pattern
"##" ".." "##" ".." "##" "##"
".." "##" "#." ".." ".." ".."
".#" "##" ".." ".." ".." "##"
```
In order to use the chunks for indexing into the rules, we have to swap the last two dimensions.
`flip` swaps the first two, so in order to lift it down to swap the second and third, we have to add
an  `each`.
```q
q)blocks:flip each size cut/:/:size cut pattern
q)blocks
"##" ".." ".." "##" "##" "##"
".." ".." "##" ".." "#." ".."
".#" ".." "##" ".." ".." "##"
```

## .d21.advance
This is the core of the simulation.
```q
q)pattern:("##.#";"##.#";"#.#.";"##..")
```
We break the pattern up into blocks depending on whether the size is divisible by 2:
```q
q)$[0=count[pattern] mod 2;2;3]
2
q)blocks:.d21.break[pattern;$[0=count[pattern] mod 2;2;3]]
q)blocks
"##" "##" ".#" ".#"
"#." "##" "#." ".."
```
We use the blocks to index into the rules:
```q
q)rule blocks
"##." "..#" "..#" ".##" "###" "##."
"..." ".##" "..." "..." "#.." ".##"
```
We reassemble the blocks into the pattern after the necessary flipping:
```q
q)flip each rule blocks
"##." ".##" "..#" "###" "..#" "##."
"..." "..." ".##" "#.." "..." ".##"
q)pattern:raze raze each/:flip each rule blocks
q)pattern
"##..##"
"..####"
"..###."
"......"
".###.."
"....##"
```

## Part 1
We call the common function with a step count of 5.
```q
    d21[5;x]
```
This cannot be demonstrated on the example input due to the rules not being exhaustive.

## Part 2
We call the common function with a step count of 18.
```q
    d21[18;x]
```
This cannot be demonstrated on the example input due to the rules not being exhaustive.
