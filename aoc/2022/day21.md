# Breakdown
Example input:
```q
x:"\n"vs"root: pppw + sjmn\ndbpl: 5\ncczh: sllz + lgvd\nzczc: 2\nptdq: humn - dvpt\ndvpt: 3\nlfqf: 4\nhumn: 5\nljgn: 2\nsjmn: drzm * dbpl\nsllz: 4\npppw: cczh / lfqf\nlgvd: ljgn * ptdq\ndrzm: hmdt - zczc\nhmdt: 32";
```

## Part 1
There are clever solutions possible for this one, but they fail to meet my conventions, mostly due to the restriction on global variables. The boring but clean version follows.

We cut the lines on the separator `: `:
```q
q)a:": "vs/:x
q)a
"root" "pppw + sjmn"
"dbpl" ,"5"
"cczh" "sllz + lgvd"
..
```
We try to parse the right sides as **floats**, which will only succeed if the right side is a number. We put the results in a dictionary.
```q
q)val:(`$a[;0])!"F"$a[;1];
q)val
root|
dbpl| 5
cczh|
zczc| 2
..
```
We compile the operations into a separate dictionary. We map the operators to their q equivalents (remembering that `/` needs to become `%`). The operator should come first, followed by the two arguments.
```q
q)op:raze{d:" "vs x 1;$[3=count d;enlist[`$x 0]!enlist(("+-*/"!(+;-;*;%))d[1;0]),`$d 0 2;()]}each a;
q)op
root| + `pppw `sjmn
cczh| + `sllz `lgvd
ptdq| - `humn `dvpt
..
```
To calculate the values, we iterate a function that fills the values dictionary with the results of each operation. We iterate until convergence.
```q
q)val:{[op;val]val^:key[op]!value[op][;0].'val 1_/:value[op];val}[op]/[val];
q)val
root| 152
dbpl| 5
cczh| 8
..
```
The answer is the value corresponding to the key `root`.
```q
q)val`root
152f
```

## Part 2
The values dictionary is initialized differently to allow mixed types:
```q
val:enlist[::]!enlist();
```
We replace the `humn` value with a symbol:
```q
val[`humn]:`humn;
```
We also change the operator for `root` to `=`, although this is mostly for safety as it should not get executed:
```q
op[`root;0]:(=);
```
When iterating the values, we change the behavior in case not both operands are numbers. In this case we create an expression tree. Due to the introduction of the `humn` symbol, this will build up one of the branches under `root`.
```q
q)val:{[op;val]val,:key[op]!value[op][;0]{$[any -9h<>type each y;x,y;x . y]}'val 1_/:value[op];val}[op]/[val];
q)val
::   | ()
`root| (=;(%;(+;4f;(*;2f;(-;`humn;3f)));4f);150f)
`dbpl| 5f
`cczh| (+;4f;(*;2f;(-;`humn;3f)))
`zczc| 2f
..
```
We swap the arguments of `root` to ensure that the expression is the first argument and the constant is the second:
```q
if[0h<>type val[`root;1]; val[`root;1 2]:val[`root;2 1]];
```
We extract the operation and the number:
```q
goalNum:val[`root;2];
goalOp:val[`root;1];
```
In a loop, we deconstruct the operation tree level by level. This requires doing the opposite operation on the goal number - we need to be careful when the number is on the left and the expression is on the right, and the operation is division or subtraction. 
```q
while[0h=type goalOp;
    $[-9h=type goalOp 2;[
        goalNum:$[(%)=first goalOp; goalNum*goalOp[2];
            (*)=first goalOp; goalNum%goalOp[2];
            (+)=first goalOp; goalNum-goalOp[2];
            (-)=first goalOp; goalNum+goalOp[2]];
        goalOp:goalOp 1;
    ];[
        goalNum:$[(%)=first goalOp; goalOp[1]%goalNum;
            (*)=first goalOp; goalNum%goalOp[1];
            (+)=first goalOp; goalNum-goalOp[1];
            (-)=first goalOp; goalOp[1]-goalNum];
        goalOp:goalOp 2;
    ]];
];
```
Once the operations are all cleared out, we are left with the answer in `goalNum`.
