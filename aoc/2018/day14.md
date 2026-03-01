# Breakdown

## Part 1
Example input:
```q
x:"9"
```
We convert the input into an integer:
```q
q)c:"J"$x
q)c
9
```
We initialize a recipe list:
```q
q)r:3 7
```
We initialize the two current positions:
```q
q)curr0:0
q)curr1:1
```
We perform an iteration until there are at least `10+c` items in the list:
```q
    while[count[r]<10+c;
        ...
    ];
```
In the iteration, we fetch the two recipes at the current locations:
```q
q)d0:r curr0
q)d1:r curr1
q)d0
3
q)d1
7
```
We append the new recipes constructed using the rules from the puzzle:
```q
q)d0+d1
10
q)string d0+d1
"10"
q)"J"$/:string d0+d1
1 0
q)r,:"J"$/:string d0+d1
q)r
3 7 1 0
```
We update the current positions based on the respective current recipes:
```q
q)curr0:(1+curr0+d0)mod count r
q)curr0
0
q)curr1:(1+curr1+d1)mod count r
q)curr1
1
```
The code for the iteration ends here.

After the iteration, we have the full recipe list:
```q
q)r
3 7 1 0 1 0 1 2 4 5 1 5 8 9 1 6 7 7 9
```
We drop the first `c` elements, take the first 10 of the remaining ones, then raze them into a
single string:
```q
q)10#c _r
5 1 5 8 9 1 6 7 7 9
q)raze string 10#c _r
"5158916779"
```

## Part 2
Example input:
```q
x:"51589"
```
We convert the input per character into integers:
```q
q)c:"J"$/:x
q)c
5 1 5 8 9
```
We initialize a recipe list:
```q
q)r:3 7
```
We initialize the two current positions:
```q
q)curr0:0
q)curr1:1
```
We cache the count of the target numbers:
```q
q)cc:count c
q)cc
5
```
We perform an iteration with no defined end point. There is a return statement in the middle.
```q
    while[1b;
        ...
    ];
```
In the iteration, we fetch the two recipes at the current locations:
```q
q)d0:r curr0
q)d1:r curr1
q)d0
3
q)d1
7
```
We append the new recipes constructed using the rules from the puzzle:
```q
q)d0+d1
10
q)string d0+d1
"10"
q)ds:"J"$/:string d0+d1
q)ds
1 0
q)r,:ds
q)r
3 7 1 0
```
We perform a check for the exit condition. This can only happen if there are enough items in the
recipe list to contain the number of recipes in the goal:
```q
    if[count[c]<=count[r];
        ...
    ];
```
To check for exit, we take the last `cc` elements from the recipe list and compare them to the
target recipes:
```q
    if[c~neg[cc]#r; ... ];
```
The return value is then the length of the list minus the length of the goal:
```q
    ... :count[r]-cc ...
```
There is an alternative check that we need to make if we just appended two recipes. If the goal was
formed after appending the first recipe, the previous check would not catch it. So we also need to
check if the goal is present in the list if we ignore the last item:
```q
    if[2=count ds;if[c~-1_(-1+neg cc)#r;:count[r]-cc+1]];
```
After the exit check, we update the current positions based on the respective current recipes:
```q
q)curr0:(1+curr0+d0)mod count r
q)curr0
0
q)curr1:(1+curr1+d1)mod count r
q)curr1
1
```
The code for the iteration ends here.

Eventually one of the exit checks will return:
```q
q)r
3 7 1 0 1 0 1 2 4 5 1 5 8 9
q)c~neg[cc]#r
1b
q)count[r]-cc
9
```
Note that this takes a long time to finish on the real input.
