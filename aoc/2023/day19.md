# Breakdown

Example input:
```q
x:"\n"vs"px{a<2006:qkq,m>2090:A,rfg}\npv{a>1716:R,A}\nlnx{m>1548:A,A}\nrfg{s<537:gd,x>2440:R,A}";
x,:"\n"vs"qs{s>3448:A,lnx}\nqkq{x<1416:A,crn}\ncrn{x>2662:A,R}\nin{s<1351:px,qqz}\nqqz{s>2770:qs,m<1801:hdj,R}";
x,:"\n"vs"gd{a>3333:R,R}\nhdj{m>838:A,pv}\n\n{x=787,m=2655,a=1222,s=2876}\n{x=1679,m=44,a=2067,s=496}";
x,:"\n"vs"{x=2036,m=264,a=79,s=2244}\n{x=2461,m=1339,a=466,s=291}\n{x=2127,m=1623,a=2188,s=1013}";
```

## Part 1
This can be solved by converting the instructions into lambdas that execute a conditional statement and then passing in the part parameters. This does require using `value` so a lot of the code will be about checking for valid input to make sure no malicious input gets through.

We separate the rules from the properties:
```q
ra:"\n"vs/:"\n\n"vs"\n"sv x
```
We split the rules into two parts, the label and the logic:
```q
q)rulep:"{"vs/:-1_/:ra 0
q)rulep
"px"  "a<2006:qkq,m>2090:A,rfg"
"pv"  "a>1716:R,A"
"lnx" "m>1548:A,A"
"rfg" "s<537:gd,x>2440:R,A"
"qs"  "s>3448:A,lnx"
"qkq" "x<1416:A,crn"
"crn" "x>2662:A,R"
"in"  "s<1351:px,qqz"
"qqz" "s>2770:qs,m<1801:hdj,R"
"gd"  "a>3333:R,R"
"hdj" "m>838:A,pv"
```
We convert each rule into a lambda. Without the input checks and with some extra indentation, the code boils down to:
```q
rule:(`$rulep[;0])!value each"{$[",/:(
        ";"sv/:{
            $[":"in x;[
                p:":"vs x;
                p2:(op:$["<"in p 0;"<";">"])vs p 0;
                s:`$p2 0;
                n:"J"$p2 1;
                "x[`",string[s],"]",op,string[n],";`",p 1
            ];
            ["`",x]]
        }each/:","vs/:rulep[;1]
    ),\:"]}";
```
We use this to convert all the rules:
```q
q)rule
px | {$[x[`a]<2006;`qkq;x[`m]>2090;`A;`rfg]}
pv | {$[x[`a]>1716;`R;`A]}
lnx| {$[x[`m]>1548;`A;`A]}
rfg| {$[x[`s]<537;`gd;x[`x]>2440;`R;`A]}
qs | {$[x[`s]>3448;`A;`lnx]}
qkq| {$[x[`x]<1416;`A;`crn]}
crn| {$[x[`x]>2662;`A;`R]}
in | {$[x[`s]<1351;`px;`qqz]}
qqz| {$[x[`s]>2770;`qs;x[`m]<1801;`hdj;`R]}
gd | {$[x[`a]>3333;`R;`R]}
hdj| {$[x[`m]>838;`A;`pv]}
```
We convert the properties of the objects by using the correct separators and doing some casting:
```q
q)ap:"="vs/:/:","vs/:1_/:-1_/:ra 1
q)ap
,"x" "787"  ,"m" "2655" ,"a" "1222" ,"s" "2876"
,"x" "1679" ,"m" "44"   ,"a" "2067" ,"s" "496"
,"x" "2036" ,"m" "264"  ,"a" "79"   ,"s" "2244"
,"x" "2461" ,"m" "1339" ,"a" "466"  ,"s" "291"
,"x" "2127" ,"m" "1623" ,"a" "2188" ,"s" "1013"
q)att:(`$ap[;;0])!'"J"$ap[;;1]
q)att
x    m    a    s
-------------------
787  2655 1222 2876
1679 44   2067 496
2036 264  79   2244
2461 1339 466  291
2127 1623 2188 1013
```
We find which objects are accepted by iterating the rules starting with the ``` `in ``` rule and finishing in the ``` `A ``` or ``` `R ``` state:
```q
q)acc:{{$[z in`A`R;z;x[z][y]]}[x;y]/[`in]}[rule]each att
q)acc
`A`R`A`R`A
```
We index into the attributes table by finding all ``` `A ``` elements in the acceptance list, then sum the values:
```q
q)where acc=`A
0 2 4
q)att where acc=`A
x    m    a    s
-------------------
787  2655 1222 2876
2036 264  79   2244
2127 1623 2188 1013
q)sum sum att where acc=`A
19114
```

## Part 2
The set of objects is now too large to pass each one through the rules. Instead we use a similar idea to day 5, only storing intervals (which in this case are 4-dimensional cuboids) and splitting them as necessary. The intervals will have lower and upper bounds of each property named `x0`, `x1`, `m0`, `m1` etc. (we will rely on this naming scheme).

We parse the rules into a nested data structure, where each element is either (property;operator;number;target) or a single symbol for the target:
```q
rule:(`$rulep[;0])!{$[":"in x;[p:":"vs x;op:$["<"in p 0;"<";">"];
    p2:op vs p 0;(`$p2 0;op;"J"$p2 1;`$p 1)];`$x]}each/:","vs/:rulep[;1]
q)rule
px | ((`a;"<";2006;`qkq);(`m;">";2090;`A);`rfg)
pv | ((`a;">";1716;`R);`A)
lnx| ((`m;">";1548;`A);`A)
rfg| ((`s;"<";537;`gd);(`x;">";2440;`R);`A)
qs | ((`s;">";3448;`A);`lnx)
qkq| ((`x;"<";1416;`A);`crn)
crn| ((`x;">";2662;`A);`R)
in | ((`s;"<";1351;`px);`qqz)
qqz| ((`s;">";2770;`qs);(`m;"<";1801;`hdj);`R)
gd | ((`a;">";3333;`R);`R)
hdj| ((`m;">";838;`A);`pv)
```
We put the splitting logic into a function named `split`. This takes either a single interval or a list of intervals, but in the list case it recursively calls itself on each element so we only have to worry about the single-element version.

First we add a new attribute called `live` and initialize it to `1b`. This is necessary because the rules should still work like conditional statements and stop processing when one of the conditions matches. Setting `live` to `0b` will make it easier to skip over already processed intervals.
```q
x[`live]:1b
```
We take the rule corresponding to the current node:
```q
r:rule x`node
```
The actual application will be an iterated (inner) function that goes through the steps in the rule. If the node is not live, we return it unchanged:
```q
if[not x`live;:enlist x]
```
If the rule part is a single element, it is the final element in the rule, so we unconditionally assign the new node before returning the element:
```q
if[1=count rs; :enlist@[x;`node`live;:;(rs;0b)]]
```
We give names to the elements of the rule part to make the code more readable:
```q
fld:rs 0; op:rs 1; num:rs 2; tgt:rs 3;
```
We also generate the names of the fields based on which field the rule checks. For example if the field is `x`, we should check `x0` and `x1`.
```q
lon:`$string[fld],"0";hin:`$string[fld],"1"
```
Based on the operation, we perform the check on the property and do one of 3 things:
* if the condition is not fulfilled, we return the node unchanged
* if the condition is fulfilled by the entire interval, we changed the node and declare the node dead before returning it
* if the condition is only fulfilled by part of the inerval, we split the node to two parts: one that is live and has the node unchanged, and one that is dead and has the node changed, with the high or low bound of the property set according to the number in the rule, adding or subtracting 1 on the side where this is necessary
```q
$[op="<";
    $[x[lon]>=num; enlist x;
      x[hin]<num; enlist @[x;`node`live;:;(tgt;0b)];
      (@[x;hin,`node`live;:;(num-1;tgt;0b)];@[x;lon;:;num])
    ];
    $[x[hin]<=num; enlist x;
      x[lon]>num; enlist @[x;`node`live;:;(tgt;0b)];
      (@[x;lon,`node`live;:;(num+1;tgt;0b)];@[x;hin;:;num])
    ]
]
```
When applying a full rule, we iterate the inner function starting with the original node and stepping through the instruction parts:
```q
res:split1/[x;r]
```
Before returning, we drop the `live` property:
```q
delete live from res
```
In the top-level function, we use a BFS to drive the splitting. We track the total of accepted items:
```q
total:0
```
We start with one interval in the queue, one that covers the entire range of the attributes:
```q
queue:enlist`x0`x1`m0`m1`a0`a1`s0`s1`node!(8#1 4000),`in
```
We iterate until the queue is empty:
```q
while[count queue; ... ]
```
We generate the next set of nodes in the queue by calling the split function:
```q
nxts:raze split[rule]each queue
```
We check for any accepted intervals and add their volume to the total:
```q
total+:exec sum (1+x1-x0)*(1+m1-m0)*(1+a1-a0)*(1+s1-s0) from nxts where node=`A
```
We drop all accepted _and_ rejected intervals from the queue:
```q
queue:delete from nxts where node in`A`R
```
After the iteration, the `total` variable contains the answer.
