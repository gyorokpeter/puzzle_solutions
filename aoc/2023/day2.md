# Breakdown

Example input:
```q
x:();
x,:enlist"Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green";
x,:enlist"Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue";
x,:enlist"Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red";
x,:enlist"Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red";
x,:enlist"Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green";
```

## Common
We will use a common function `d2` to convert the input into a regular format.

We start by splitting the input. Various splits are needed and at various depths, so we need to use the correct number of `/:` (each-right) iterators with `vs` to make sure it is applied at the correct level. We also drop the game identifier as it is easy to reconstruct from the row index.
```q
q)": "vs/:x
"Game 1" "3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
"Game 2" "1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue"
"Game 3" "8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red"
"Game 4" "1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red"
"Game 5" "6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
q)last each": "vs/:x
"3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
"1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue"
"8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red"
"1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red"
"6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
q)"; "vs/:last each": "vs/:x
("3 blue, 4 red";"1 red, 2 green, 6 blue";"2 green")
("1 blue, 2 green";"3 green, 4 blue, 1 red";"1 green, 1 blue")
("8 green, 6 blue, 20 red";"5 blue, 4 red, 13 green";"5 green, 1 red")
("1 green, 3 red, 6 blue";"3 green, 6 red";"3 green, 15 blue, 14 red")
("6 red, 1 blue, 3 green";"2 blue, 1 red, 2 green")
q)", "vs/:/:"; "vs/:last each": "vs/:x
(("3 blue";"4 red");("1 red";"2 green";"6 blue");,"2 green")
(("1 blue";"2 green");("3 green";"4 blue";"1 red");("1 green";"1 blue"))
(("8 green";"6 blue";"20 red");("5 blue";"4 red";"13 green");("5 green";"1 red"))
(("1 green";"3 red";"6 blue");("3 green";"6 red");("3 green";"15 blue";"14 red"))
(("6 red";"1 blue";"3 green");("2 blue";"1 red";"2 green"))
q)a:" "vs/:/:/:", "vs/:/:"; "vs/:last each": "vs/:x
q)a
(((,"3";"blue");(,"4";"red"));((,"1";"red");(,"2";"green");(,"6";"blue"));,(,"2";"green"))
(((,"1";"blue");(,"2";"green"));((,"3";"green");(,"4";"blue");(,"1";"red"));((,"1";"green");(,"1";"blue")))
(((,"8";"green");(,"6";"blue");("20";"red"));((,"5";"blue");(,"4";"red");("13";"green"));((,"5";"green");(,"1";"red")))
(((,"1";"green");(,"3";"red");(,"6";"blue"));((,"3";"green");(,"6";"red"));((,"3";"green");("15";"blue");("14";"red")))
(((,"6";"red");(,"1";"blue");(,"3";"green"));((,"2";"blue");(,"1";"red");(,"2";"green")))
```
We parse the numbers using `"J"$` and also turn the colors into small integers by looking them up in the list `("red";"green";"blue")`, so red becomes 0, green becomes 1 and blue becomes 2.
```q
q)num
(3 4;1 2 6;,2)
(1 2;3 4 1;1 1)
(8 6 20;5 4 13;5 1)
(1 3 6;3 6;3 15 14)
(6 1 3;2 1 2)
q)typ:("red";"green";"blue")?a[;;;1]
q)typ
(2 0;0 1 2;,1)
(2 1;1 2 0;1 2)
(1 2 0;2 0 1;1 0)
(1 0 2;1 0;1 2 0)
(0 2 1;2 0 1)
```
The problem is that the colors are not always in the right order and colors may be missing. However there is a fix for this: if we start with a list containing `0 0 0`, and we use elementwise assignment with the colors as the index and the numbers as the value to be assigned, we will get a list with the red, green and blue values in the correct order. This can be expressed as a [functional amend](https://code.kx.com/q/ref/apply/#amend-amend-at) - the operator will be `@` since we are assigning to a one-dimensional list, the data (destination) will be `0 0 0`, and the operation will be `:` for simple assignment. We elide the second and fourth argument, as these correspond to `typ` and `num` respectively. To apply the amend at the correct level, we need to use the `'` (each) iterator twice.
```q
q)@[0 0 0;;:;]''[typ;num]
(4 0 3;1 2 6;0 2 0)
(0 2 1;1 3 4;0 1 1)
(20 8 6;4 13 5;1 5 0)
(3 1 6;6 3 0;14 3 15)
(6 3 1;1 2 2)
```
This will be the return value of `d2`.

# Part 1
We need to compare the output of `d2` to the constant list `12 13 14`. To apply the comparison at the right level, we need to use two `/:` (each-right) iterators, as the lists are two levels down.
```q
q)12 13 14>=/:/:d2 x
(111b;111b;111b)
(111b;111b;111b)
(011b;111b;111b)
(111b;111b;010b)
(111b;111b)
```
A particular pull is only possible if all 3 booleans for the pull are `1b`. We can check this by using `all` two levels down. For a unary function, `each` pushes it down one level, but this only works once. If we want to push it more levels down we have to use additional `/:` iterators on `each`, so two levels down is `each/:`. (We could also write `(all each)each` but that is ugly.)
```q
q)all each/:12 13 14>=/:/:d2 x
111b
111b
011b
110b
11b
```
A game is only possible if all pulls in it are possible, so this can be checked with another use of `all`, this time only pushed down one level:
```q
q)all each all each/:12 13 14>=/:/:d2 x
11001b
```
To find the numbers of the possible games, we need to get the indices of the `1b` values in the list, which is what the `where` function does, then add one:
```q
q)1+where all each all each/:12 13 14>=/:/:d2 x
1 2 5
```
The answer is the sum of these values:
```q
q)sum 1+where all each all each/:12 13 14>=/:/:d2 x
8
```

## Part 2
To find the minimum number of cubes required, we need to find the maximum of the red, green and blue cubes over all pulls of the game. Using `max` on a single game (which is a list of list of 3 numbers each) does exactly this, so to push it to the right level we need just one `each`.
```q
q)max each d2 x
4  2  6
1  3  4
20 13 6
14 3  15
6  3  2
```
We can then find the product of each row using `prd`, once again pushed down one level:
```q
q)prd each max each d2 x
48 12 1560 630 36
```
The answer is the sum of these values:
q)sum prd each max each d2 x
2286
